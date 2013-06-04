#
# * grunt-blitz
# * https://github.com/CDSMOpen/blitzer_poc
# *
# * Copyright (c) 2013 Darren Wallace
# * Licensed under the MIT license.
# 
"use strict"
Blitzer = require '../lib/blitzer'

module.exports = (grunt) ->
  # Please see the Grunt documentation for more information regarding task
  # creation: http://gruntjs.com/creating-tasks
  grunt.registerMultiTask "blitz", "Run blitz.io sprints and rushes from grunt", ->     
    done = @async()


    # Merge task-specific and/or target-specific options with these defaults.

    options = @options(
      blitzid: grunt.option 'blitzid'
      blitzkey: grunt.option 'blitzkey'
      logPath: grunt.option 'logPath'
    )

    @requiresConfig "blitzid" unless options.blitzid?
    @requiresConfig "blitzkey" unless options.blitzkey?

    blitz = new Blitzer options.blitzid, options.blitzkey, options
    blitz.run done


    


