"use strict"

Blitz = require 'blitz'
Winston = require 'winston'

module.exports = class Blitzer
	constructor: (@blitzId, @blitzKey, @options)->

		@blitz = new Blitz @blitzid, @blitzkey
		@logger = new Winston.logger transports: [
			new Winston.transports.Console()
		]


		@_addLogging @options.logPath if @options.logPath
	
	run: (done)-> 	
		if @options.blitz?
			@blitz.execute @options.blitz 
		else 
			done() if done?

		@blitz.on "error", (response)=>
			console.log "Errrrrrrrror"
			@logger.error "error: "+ response.error
			@logger.error "reason: "+ response.reason
			done()

		@blitz.on "complete", (data)=>
			@logger.log "Region: "+ data.region
			@logger.log "Duration: "+ data.duration

			for step in data.steps
				@logger.log "Connect: "+ step.connect
				@logger.log "Duration: "+ step.duration

				@logger.dir step

			done()

	_addLogging: (logPath)->
		@logger.add new Winston.transports.File filename: logPath


