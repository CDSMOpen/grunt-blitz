#
# * grunt-blitz
# * https://github.com/CDSMOpen/blitzer_poc
# *
# * Copyright (c) 2013 Darren Wallace
# * Licensed under the MIT license.
# 
"use strict"
Blitz = require 'blitz'

module.exports = (grunt) ->
  
  # Please see the Grunt documentation for more information regarding task
  # creation: http://gruntjs.com/creating-tasks
  grunt.registerMultiTask "blitz", "Run blitz.io sprints and rushes from grunt", ->
    
    # Merge task-specific and/or target-specific options with these defaults.
     
    done = @async()

    options = @options(
      blitzid: grunt.option 'blitzid'
      blitzkey: grunt.option 'blitzkey'
    )

    @requiresConfig "blitzid" unless options.blitzid?
    @requiresConfig "blitzkey" unless options.blitzkey?

    grunt.log.writeln "Using blitz id: #{options.blitzid}"
    grunt.log.writeln "Using blitz key: #{options.blitzkey}"

    blitz = new Blitz options.blitzid, options.blitzkey

    sprint = blitz.sprint({
      steps: [{url: options.url}]
      region: 'ireland'
    })

    sprint.on "complete", (data)->
      console.log "Region: "+ data.region
      console.log "Duration: "+ data.duration

      for step in data.steps
        console.log "Connect: "+ step.connect
        console.log "Duration: "+ step.duration

        console.dir step
      done()

    sprint.on "error", (response)->
      console.log "error: "+ response.error
      console.log "reason: "+ response.reason
      done()


    


