"use strict"

Blitz = require 'blitz'
Winston = require 'winston'
Hash = require 'hashish'

module.exports = class Blitzer
	@DEFAULTS:
		eventPatterns: 
			blitzStart: "Blitz start: %s"
			blitzError: "Blitz error: %s"
			blitzFail: "Blitz failed: %s"
			blitzComplete: "Blitz complete: %s"
		appdex:
			fails: 10
			avgResponse: 5

	constructor: (@blitzId, @blitzKey, options)->
		@options = Hash.update Blitzer.DEFAULTS, options
		@blitz = new Blitz @blitzId, @blitzKey
		@logger = @_makeLogger()
		@_addFileLogging(@logger, @options.logPath) if @options.logPath

	run: (done) -> 	
		if @options.blitz?
			@startTime = process.hrtime()
			rush = @blitz.execute @options.blitz 
			@logger.log 'event', @options.eventPatterns.blitzStart, @options.blitz
		else 
			return done() if done?

		rush.on "error", (response) =>
			@logger.error "error: " + response.error, response
			@logger.log "event", @options.eventPatterns.blitzError, response.error, response
			done()

		rush.on "complete", (data) =>
			if data.timeline?
				totalErrorsAndTimeouts = 0
				duration = 0

				for point in data.timeline
	       			duration += point.duration
	       			totalErrorsAndTimeouts += point.timeouts + point.errors
	            	
	        	avgduration = duration / data.timeline.length

	        	if avgduration > @options.appdex.avgResponse
	        		@logger.log "event", @options.eventPatterns.blitzFail, avgduration
	        	if totalErrorsAndTimeouts > @options.appdex.fails
	        		@logger.log "event", @options.eventPatterns.blitzFail, totalErrorsAndTimeouts 
	        else
	        	if data.duration > @options.appdex.avgResponse
	        		@logger.log "event", @options.eventPatterns.blitzFail, data.duration

			@logger.log "event", @options.eventPatterns.blitzComplete, process.hrtime(@startTime)[0]
			done()

	_addFileLogging: (logger, logPath) ->
		logger.info "logging to file ", logPath
		logger.add Winston.transports.File, 
			filename: logPath
			colorize: false
			json: true
			level: 'data'

	_makeLogger: (logPath) ->
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
				data: 0
			colors:
				event: 'white'
				info: 'white'
				warn: 'yellow'
				error: 'red'
				data: 'white'
		}


