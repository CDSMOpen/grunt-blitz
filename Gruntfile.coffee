#
# * grunt-blitz
# * https://github.com/CDSMOpen/blitzer_poc
# *
# * Copyright (c) 2013 Darren Wallace
# * Licensed under the MIT license.
# 
"use strict"
module.exports = (grunt) ->
  
  # Project configuration.
  grunt.initConfig
    jshint:
      all: ["Gruntfile.js", "tasks/*.js", "<%= nodeunit.tests %>"]
      options:
        jshintrc: ".jshintrc"

    watch:
      mochacli:
        files: ["test/**/*test.coffee"]
        tasks: ["mochacli:spec"]

      compile:
        files: ["src/**/*.coffee"]
        tasks: ["coffee:compile", "mochacli:spec"]

    
    # Before generating any new files, remove any previously-created files.
    clean:
      tests: ["tmp"]

    coffee:
      compile:
        expand: true
        cwd: 'src'
        src: ['**/*.coffee']
        dest: 'tasks'
        ext: '.js'
    
    mochacli:
      options:
        compilers: ['coffee:coffee-script']
        reporter: 'spec'
        require: ['test/test_helpers.coffee']
        growl: true
        files: 'test/**/*test.coffee'

      spec:
        options:
          reporter: 'spec'
        
      nyan:
        options:
          reporter: 'nyan'
    
    # Configuration to be run (and then tested).
    blitz:
      # options:
      #   blitzid: 'software@cdsm.co.uk' 
      #   blitzkey: 'your_blitz_api_key_here'


      cdsm:
        options: 
          url: 'http://www.cdsm.co.uk'
      


  
  # Actually load this plugin's task(s).
  grunt.loadTasks "tasks"
  
  # These plugins provide necessary tasks.
  grunt.loadNpmTasks "grunt-contrib-jshint"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-mocha-cli"
  grunt.loadNpmTasks "grunt-contrib-watch"
  
  # Whenever the "test" task is run, first clean the "tmp" dir, then run this
  # plugin's task(s), then test the result.
  grunt.registerTask "test", ["clean", "coffee", "mochacli:spec"]
  
  # By default, lint and run all tests.
  grunt.registerTask "default", ["test", "watch"]