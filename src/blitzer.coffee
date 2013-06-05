"use strict"

Blitz = require 'blitz'
Winston = require 'winston'
Hash = require 'hashish'

module.exports = class Blitzer
	@DEFAULTS:
		eventPatterns: 
			blitzStart: "Blitz start: %s"
			blitzError: "Blitz error: %s"
			blitzComplete: "Blitz complete: %s"

	constructor: (@blitzId, @blitzKey, options)->
		@options = Hash.update options, Blitzer.DEFAULTS
		@blitz = new Blitz @blitzId, @blitzKey
		@logger = @_makeLogger()
		@_addFileLogging(@logger, @options.logPath) if @options.logPath


	run: (done)-> 	
		if @options.blitz?
			rush = @blitz.execute @options.blitz 
			@logger.log 'event', @options.eventPatterns.blitzStart, @options.blitz
		else 
			done() if done?

		rush.on "error", (response)=>
			@logger.error "error: "+ response.error, response
			@logger.log "event", @options.eventPatterns.blitzError, response.error, response
			done()

		rush.on "complete", (data)=>
			@logger.info "Blitz Complete in "+ data.duration
			@logger.info data
			@logger.log "event", @options.eventPatterns.blitzComplete, data.duration

			for step in data.steps
				@logger.info "Step: "+ step.connect, step

			done()

	_addFileLogging: (logger, logPath)->
		logger.info "logging to file ", logPath
		logger.add Winston.transports.File, 
			filename: logPath
			colorize: false
			json: true
			level: 'event'

	_makeLogger: (logPath)->
		customLevels = @_getLogLevels()
		logger = new Winston.Logger {
			transports: [
				new (Winston.transports.Console)({
					colorize: true
					level: 'event'
				})
			]
			levels: customLevels.levels
			colors: customLevels.colors
		} 
		logger

	_getLogLevels: ->
		customLevels = {
			levels:
				event: 1
				info: 2
				warn: 3
				error: 4
			colors:
				event: 'white'
				info: 'white'
				warn: 'yellow'
				error: 'red'
		}


