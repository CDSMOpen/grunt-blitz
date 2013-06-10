#
# * grunt-blitz
# * https://github.com/CDSMOpen/blitzer_poc
# *
# * Copyright (c) 2013 Darren Wallace
# * Licensed under the MIT license.
# 
"use strict"
Blitzer = require '../lib/blitzer'
path = require 'path'

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

    # create the log directory if necessary
    logDir = path.dirname path.resolve( process.cwd(), options.logPath )

    unless grunt.file.isDir( logDir )
      console.log "Creating log directory"
      grunt.file.mkdir logDir 

    @requiresConfig "blitzid" unless options.blitzid?
    @requiresConfig "blitzkey" unless options.blitzkey?
    @requiresConfig "blitz" unless options.blitz?

    blitz = new Blitzer options.blitzid, options.blitzkey, options
    blitz.run done


    


