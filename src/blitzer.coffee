"use strict"

Blitz = require 'blitz'
Winston = require 'winston'
Hash = require 'hashish'

module.exports = class Blitzer
	@DEFAULTS:
		eventPatterns: 
			blitzStart: "Blitz start: %s"
			blitzError: "Blitz error: %s %s"
			blitzFail: "Blitz failed: %s %s"
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
		runname = ""		
		if @options.blitz?
			runname = @cleanBlitzStr @options.blitz
			rush = @blitz.execute @options.blitz 			
			@logger.log 'event', @options.eventPatterns.blitzStart, runname
		else 
			return done() if done?

		rush.on "error", (response) =>
			@logger.log "event", @options.eventPatterns.blitzError, runname, response.error
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
	        		@logger.log "event", @options.eventPatterns.blitzFail, runname, avgduration
	        	else if totalErrorsAndTimeouts > @options.appdex.fails
	        		@logger.log "event", @options.eventPatterns.blitzFail, runname, totalErrorsAndTimeouts 
	        else
	        	if data.duration > @options.appdex.avgResponse
	        		@logger.log "event", @options.eventPatterns.blitzFail, runname, data.duration

			@logger.log "event", @options.eventPatterns.blitzComplete, runname
			done()

	# Clean the blitz string to remove any string breaking characters so logging is nicer
	cleanBlitzStr: (blitzStr) ->
		blitzStr.replace(/[^\w\s-:,\/.]/gi, '')

	_addFileLogging: (logger, logPath) ->
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


