#
# * grunt-blitz
# * https://github.com/CDSMOpen/blitzer_poc
# *
# * Copyright (c) 2013 Darren Wallace
# * Licensed under the MIT license.
# 
"use strict"
module.exports = (grunt) ->
  
  # Please see the Grunt documentation for more information regarding task
  # creation: http://gruntjs.com/creating-tasks
  grunt.registerMultiTask "blitz", "Run blitz.io sprints and rushes here", ->
    
    # Merge task-specific and/or target-specific options with these defaults.
     
    
    options = @options(
      punctuation: "."
      separator: ", "
      blitzid: grunt.option 'blitzid'
      blitzkey: grunt.option 'blitzkey'
    )

    @requiresConfig "blitzid" unless options.blitzid?
    @requiresConfig "blitzkey" unless options.blitzkey?

    grunt.log.writeln "Using blitz id: #{options.blitzid}"
    grunt.log.writeln "Using blitz key: #{options.blitzkey}"

    
    # # Iterate over all specified file groups.
    # @files.forEach (f) ->
      
    #   # Concat specified files.
      
    #   # Warn on and remove invalid source files (if nonull was set).
      
    #   # Read file source.
    #   src = f.src.filter((filepath) ->
    #     unless grunt.file.exists(filepath)
    #       grunt.log.warn "Source file \"" + filepath + "\" not found."
    #       false
    #     else
    #       true
    #   ).map((filepath) ->
    #     grunt.file.read filepath
    #   ).join(grunt.util.normalizelf(options.separator))
      
    #   # Handle options.
    #   src += options.punctuation
      
    #   # Write the destination file.
    #   grunt.file.write f.dest, src
      
    #   # Print a success message.
    #   grunt.log.writeln "File \"" + f.dest + "\" created."

