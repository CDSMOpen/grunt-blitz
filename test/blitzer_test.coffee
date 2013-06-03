grunt = require 'grunt'
hashish = require 'hashish'
SandboxedModule = require 'sandboxed-module'
winston = require 'winston'

# set up sandboxed modules

blitzInstance = {
	execute: (command)->
		console.log "Executing command '#{command}'"
}

rushInstance = {
	on: (event, callback)->
		console.log "Listening to #{event}"
}

winstonInstance = {
	transports:
		Console: sinon.stub()
		File: sinon.stub()
	logger: (options)->
		console.log "new logger"
}

loggerInstance = {
	add: ->
		# console.log "Adding log"
	log: sinon.stub()
	error: sinon.stub()
}

blitzConstructor = sinon.stub().returns blitzInstance
winstonConstructor = sinon.stub().returns winstonInstance


blitzer = SandboxedModule.require  '../src/blitzer',
	requires:
		'blitz': blitzConstructor
		'winston': winstonInstance
	locals:
		options:
			blitz: '-r ireland http://www.cdsm.co.uk'


describe "blitzer", ->
	describe "creation", ->
		beforeEach ->
			blitzOptions = {
			}
			sinon.stub winstonInstance, 'logger'
			@sut = new blitzer( 'myBlitzId@duff.com','some-blitz-id', blitzOptions)

		afterEach ->
			winstonInstance.logger.restore()

		it "should create a blitz instance", ->
			blitzConstructor.should.have.been.calledWithNew

		it "should create a log if requested", ->
			blitzConstructor.should.have.been.called

		describe "logging with no options.logPath defined", ->
			it "should only log to the console", ->
				winstonInstance.transports.Console.should.have.been.calledWithNew
				winstonInstance.transports.File.should.not.have.been.calledWithNew

	describe "running a blitz", ->
		beforeEach ->
			blitzOptions = 
				blitz: '-r ireland http://www.cdsm.co.uk'
				logPath: './some/duff/file.txt'
			sinon.stub(blitzInstance, 'execute').returns rushInstance
			sinon.stub rushInstance, 'on'
			sinon.stub( winstonInstance, 'logger').returns loggerInstance
			sinon.stub loggerInstance, 'add'

			rushInstance.on.withArgs("complete").yields {
				region: 'ireland'
				duration: 10
				steps: []
			}

			@sut = new blitzer( 'myBlitzId@duff.com','some-blitz-id', blitzOptions)

		afterEach ->
			blitzInstance.execute.restore()
			rushInstance.on.restore()
			winstonInstance.logger.restore()
			loggerInstance.add.restore()

		it "should use blitz to run the test", (done)->
			@sut.run ->
				blitzInstance.execute.should.have.been.calledOnce
				done()

		it "should pass the test string to blitz execute", (done)->
			@sut.run ->
				blitzInstance.execute.should.have.been.calledWith '-r ireland http://www.cdsm.co.uk'
				done()

		describe "logging with options.logPath defined", ->
			it "should log to the console", ->
				winstonInstance.transports.Console.should.have.been.calledWithNew

			it "should log to the path provided", ->
				winstonInstance.transports.File.should.have.been.calledWithNew
				loggerInstance.add.should.have.been.calledOnce

		describe "on complete", ->
			it "should log the blitz results", (done)->
				@sut.run ->
					loggerInstance.log.should.have.been.called
					done()

	describe "log errors", ->
		beforeEach ->
			blitzOptions = 
				blitz: '-r ireland http://www.cdsm.co.uk'
				logPath: './some/duff/file.txt'
			sinon.stub( blitzInstance, 'execute').returns rushInstance
			sinon.stub rushInstance, 'on'
			sinon.stub( winstonInstance, 'logger').returns loggerInstance
			sinon.stub loggerInstance, 'add'

			rushInstance.on.withArgs("error").yields {
				error: 'duff error'
				reason: 'error description'
			}

			@sut = new blitzer( 'myBlitzId@duff.com','some-blitz-id', blitzOptions)

		afterEach ->
			blitzInstance.execute.restore()
			rushInstance.on.restore()
			winstonInstance.logger.restore()
			loggerInstance.add.restore()

		it "should log the blitz error", (done)->
			@sut.run ->
				loggerInstance.error.should.have.been.called
				done()

