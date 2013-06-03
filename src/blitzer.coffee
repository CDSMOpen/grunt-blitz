"use strict"

Blitz = require 'blitz'
Winston = require 'winston'

module.exports = class Blitzer
	constructor: (@blitzId, @blitzKey, @options)->
		@blitz = new Blitz @blitzid, @blitzkey
		console.log "Making blitzer"

		@logger = new Winston.logger {
			transports: [
				new (Winston.transports.Console)()
			]
		} 
		console.log "Logger ready"

		@_addLogging @options.logPath if @options.logPath

		console.log "File transport added"
	
	run: (done)-> 	
		if @options.blitz?
			rush = @blitz.execute @options.blitz 
		else 
			done() if done?

		rush.on "error", (response)=>
			@logger.error "error: "+ response.error
			@logger.error "reason: "+ response.reason, response
			done()

		rush.on "complete", (data)=>
			@logger.log "Region: "+ data.region
			@logger.log "Duration: "+ data.duration

			for step in data.steps
				@logger.log "Step: "+ step.connect, step

			done()

	_addLogging: (logPath)->
		@logger.add new Winston.transports.File filename: logPath


