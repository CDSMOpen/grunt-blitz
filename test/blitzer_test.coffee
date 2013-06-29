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
	Logger: (options)->
		console.log "new logger"
}

loggerInstance = {
	add: ->
		# console.log "Adding log"
	log: sinon.stub()
	error: sinon.stub()
	info: sinon.stub()
	event: sinon.stub()
	data: sinon.stub()
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
			sinon.stub winstonInstance, 'Logger'
			@sut = new blitzer( 'myBlitzId@duff.com','some-blitz-id', blitzOptions)

		afterEach ->
			winstonInstance.Logger.restore()

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
			@blitzOptions = 
				blitz: '-r ireland http://www.cdsm.co.uk'
				logPath: './some/duff/file.txt'
				eventPatterns: 
					blitzStart: "## Blitz start %s"
					blitzError: "## Blitz error %s"
					blitzComplete: "## Blitz complete"
				appdex:
					avgResponse: 2
					fails: 0

			sinon.stub(blitzInstance, 'execute').returns rushInstance
			sinon.stub rushInstance, 'on'
			sinon.stub( winstonInstance, 'Logger').returns loggerInstance
			sinon.stub loggerInstance, 'add'

			step1 = {
				duration: 1
				timeouts: 0
				errors: 0
			}

			rushInstance.on.withArgs("complete").yields {
				region: 'ireland'
				duration: 10
				steps: [step1]
			}

			@sut = new blitzer( 'myBlitzId@duff.com','some-blitz-id', @blitzOptions)

		afterEach ->
			blitzInstance.execute.restore()
			rushInstance.on.restore()
			winstonInstance.Logger.restore()
			loggerInstance.add.restore()

		it "should use blitz to run the test", (done)->
			@sut.run ->
				blitzInstance.execute.should.have.been.calledOnce
				done()

		it "should pass the test string to blitz execute", (done)->
			@sut.run ->
				blitzInstance.execute.should.have.been.calledWith '-r ireland http://www.cdsm.co.uk'
				done()
		it "should log a blitz start event", (done)->
			@sut.run =>
				loggerInstance.log.should.have.been.calledWith 'event', @blitzOptions.eventPatterns.blitzStart, '-r ireland http://www.cdsm.co.uk'
				done()

		describe "logging with options.logPath defined", ->
			it "should log to the console", ->
				winstonInstance.transports.Console.should.have.been.calledWithNew

			it "should log to the path provided", ->
				loggerInstance.add.should.have.been.calledWith winstonInstance.transports.File

		describe "on complete", ->
			it "should NOT log the blitz fail event", (done)->
				@sut.run =>
					loggerInstance.log.should.not.have.been.calledWith "event", @blitzOptions.eventPatterns.blitzFail
					done()
			it "should log the blitz results", (done)->
				@sut.run =>
					loggerInstance.info.should.have.been.called
					done()
			it "should log the blitz complete event", (done)->
				@sut.run =>
					loggerInstance.log.should.have.been.calledWith "event", @blitzOptions.eventPatterns.blitzComplete
					done()

	describe "running a blitz with fails appdex due to errors", ->
		beforeEach ->
			@blitzOptions = 
				blitz: '-r ireland http://www.cdsm.co.uk'
				logPath: './some/duff/file.txt'
				eventPatterns: 
					blitzStart: "## Blitz start %s"
					blitzError: "## Blitz error %s"
					blitzFail: "## Blitz failed: %s"
					blitzComplete: "## Blitz complete"
				appdex:
					fails: 1
					avgResponse: 2

			sinon.stub(blitzInstance, 'execute').returns rushInstance
			sinon.stub rushInstance, 'on'
			sinon.stub( winstonInstance, 'Logger').returns loggerInstance
			sinon.stub loggerInstance, 'add'

			step1 = {
				duration: 1
				timeouts: 0
				errors: 2
			}

			rushInstance.on.withArgs("complete").yields {
				region: 'ireland'
				duration: 10
				steps: [step1]
			}

			@sut = new blitzer( 'myBlitzId@duff.com','some-blitz-id', @blitzOptions)

		afterEach ->
			blitzInstance.execute.restore()
			rushInstance.on.restore()
			winstonInstance.Logger.restore()
			loggerInstance.add.restore()

		it "should use blitz to run the test", (done)->
			@sut.run ->
				blitzInstance.execute.should.have.been.calledOnce
				done()

		it "should pass the test string to blitz execute", (done)->
			@sut.run ->
				blitzInstance.execute.should.have.been.calledWith '-r ireland http://www.cdsm.co.uk'
				done()
		it "should log a blitz start event", (done)->
			@sut.run =>
				loggerInstance.log.should.have.been.calledWith 'event', @blitzOptions.eventPatterns.blitzStart, '-r ireland http://www.cdsm.co.uk'
				done()

		describe "logging with options.logPath defined", ->
			it "should log to the console", ->
				winstonInstance.transports.Console.should.have.been.calledWithNew

			it "should log to the path provided", ->
				loggerInstance.add.should.have.been.calledWith winstonInstance.transports.File

		describe "on complete", ->
			it "should log the blitz fail event", (done)->
				@sut.run =>
					loggerInstance.log.should.have.been.calledWith "event", @blitzOptions.eventPatterns.blitzFail
					done()
			it "should log the blitz results", (done)->
				@sut.run =>
					loggerInstance.info.should.have.been.called
					done()
			it "should log the blitz complete event", (done)->
				@sut.run =>
					loggerInstance.log.should.have.been.calledWith "event", @blitzOptions.eventPatterns.blitzComplete
					done()

	describe "running a blitz with fails appdex due to timeouts", ->
		beforeEach ->
			@blitzOptions = 
				blitz: '-r ireland http://www.cdsm.co.uk'
				logPath: './some/duff/file.txt'
				eventPatterns: 
					blitzStart: "## Blitz start %s"
					blitzError: "## Blitz error %s"
					blitzFail: "## Blitz failed: %s"
					blitzComplete: "## Blitz complete"
				appdex:
					fails: 1
					avgResponse: 2

			sinon.stub(blitzInstance, 'execute').returns rushInstance
			sinon.stub rushInstance, 'on'
			sinon.stub( winstonInstance, 'Logger').returns loggerInstance
			sinon.stub loggerInstance, 'add'

			step1 = {
				duration: 1
				timeouts: 2
				errors: 0
			}

			rushInstance.on.withArgs("complete").yields {
				region: 'ireland'
				duration: 10
				steps: [step1]
			}

			@sut = new blitzer( 'myBlitzId@duff.com','some-blitz-id', @blitzOptions)

		afterEach ->
			blitzInstance.execute.restore()
			rushInstance.on.restore()
			winstonInstance.Logger.restore()
			loggerInstance.add.restore()

		it "should use blitz to run the test", (done)->
			@sut.run ->
				blitzInstance.execute.should.have.been.calledOnce
				done()

		it "should pass the test string to blitz execute", (done)->
			@sut.run ->
				blitzInstance.execute.should.have.been.calledWith '-r ireland http://www.cdsm.co.uk'
				done()
		it "should log a blitz start event", (done)->
			@sut.run =>
				loggerInstance.log.should.have.been.calledWith 'event', @blitzOptions.eventPatterns.blitzStart, '-r ireland http://www.cdsm.co.uk'
				done()

		describe "logging with options.logPath defined", ->
			it "should log to the console", ->
				winstonInstance.transports.Console.should.have.been.calledWithNew

			it "should log to the path provided", ->
				loggerInstance.add.should.have.been.calledWith winstonInstance.transports.File

		describe "on complete", ->
			it "should log the blitz fail event", (done)->
				@sut.run =>
					loggerInstance.log.should.have.been.calledWith "event", @blitzOptions.eventPatterns.blitzFail
					done()
			it "should log the blitz results", (done)->
				@sut.run =>
					loggerInstance.info.should.have.been.called
					done()
			it "should log the blitz complete event", (done)->
				@sut.run =>
					loggerInstance.log.should.have.been.calledWith "event", @blitzOptions.eventPatterns.blitzComplete
					done()

	describe "running a blitz with fails appdex due to timeouts and errors", ->
		beforeEach ->
			@blitzOptions = 
				blitz: '-r ireland http://www.cdsm.co.uk'
				logPath: './some/duff/file.txt'
				eventPatterns: 
					blitzStart: "## Blitz start %s"
					blitzError: "## Blitz error %s"
					blitzFail: "## Blitz failed: %s"
					blitzComplete: "## Blitz complete"
				appdex:
					fails: 1
					avgResponse: 2

			sinon.stub(blitzInstance, 'execute').returns rushInstance
			sinon.stub rushInstance, 'on'
			sinon.stub( winstonInstance, 'Logger').returns loggerInstance
			sinon.stub loggerInstance, 'add'

			step1 = {
				duration: 1
				timeouts: 1
				errors: 1
			}

			rushInstance.on.withArgs("complete").yields {
				region: 'ireland'
				duration: 10
				steps: [step1]
			}

			@sut = new blitzer( 'myBlitzId@duff.com','some-blitz-id', @blitzOptions)

		afterEach ->
			blitzInstance.execute.restore()
			rushInstance.on.restore()
			winstonInstance.Logger.restore()
			loggerInstance.add.restore()

		it "should use blitz to run the test", (done)->
			@sut.run ->
				blitzInstance.execute.should.have.been.calledOnce
				done()

		it "should pass the test string to blitz execute", (done)->
			@sut.run ->
				blitzInstance.execute.should.have.been.calledWith '-r ireland http://www.cdsm.co.uk'
				done()
		it "should log a blitz start event", (done)->
			@sut.run =>
				loggerInstance.log.should.have.been.calledWith 'event', @blitzOptions.eventPatterns.blitzStart, '-r ireland http://www.cdsm.co.uk'
				done()

		describe "logging with options.logPath defined", ->
			it "should log to the console", ->
				winstonInstance.transports.Console.should.have.been.calledWithNew

			it "should log to the path provided", ->
				loggerInstance.add.should.have.been.calledWith winstonInstance.transports.File

		describe "on complete", ->
			it "should log the blitz fail event", (done)->
				@sut.run =>
					loggerInstance.log.should.have.been.calledWith "event", @blitzOptions.eventPatterns.blitzFail
					done()
			it "should log the blitz results", (done)->
				@sut.run =>
					loggerInstance.info.should.have.been.called
					done()
			it "should log the blitz complete event", (done)->
				@sut.run =>
					loggerInstance.log.should.have.been.calledWith "event", @blitzOptions.eventPatterns.blitzComplete
					done()

	describe "running a blitz with fails appdex due to duration", ->
		beforeEach ->
			@blitzOptions = 
				blitz: '-r ireland http://www.cdsm.co.uk'
				logPath: './some/duff/file.txt'
				eventPatterns: 
					blitzStart: "## Blitz start %s"
					blitzError: "## Blitz error %s"
					blitzFail: "## Blitz failed: %s"
					blitzComplete: "## Blitz complete"
				appdex:
					fails: 1
					avgResponse: 2

			sinon.stub(blitzInstance, 'execute').returns rushInstance
			sinon.stub rushInstance, 'on'
			sinon.stub( winstonInstance, 'Logger').returns loggerInstance
			sinon.stub loggerInstance, 'add'

			step1 = {
				duration: 3
				timeouts: 0
				errors: 0
			}

			rushInstance.on.withArgs("complete").yields {
				region: 'ireland'
				duration: 10
				steps: [step1]
			}

			@sut = new blitzer( 'myBlitzId@duff.com','some-blitz-id', @blitzOptions)

		afterEach ->
			blitzInstance.execute.restore()
			rushInstance.on.restore()
			winstonInstance.Logger.restore()
			loggerInstance.add.restore()

		it "should use blitz to run the test", (done)->
			@sut.run ->
				blitzInstance.execute.should.have.been.calledOnce
				done()

		it "should pass the test string to blitz execute", (done)->
			@sut.run ->
				blitzInstance.execute.should.have.been.calledWith '-r ireland http://www.cdsm.co.uk'
				done()
		it "should log a blitz start event", (done)->
			@sut.run =>
				loggerInstance.log.should.have.been.calledWith 'event', @blitzOptions.eventPatterns.blitzStart, '-r ireland http://www.cdsm.co.uk'
				done()

		describe "logging with options.logPath defined", ->
			it "should log to the console", ->
				winstonInstance.transports.Console.should.have.been.calledWithNew

			it "should log to the path provided", ->
				loggerInstance.add.should.have.been.calledWith winstonInstance.transports.File

		describe "on complete", ->
			it "should log the blitz fail event", (done)->
				@sut.run =>
					loggerInstance.log.should.have.been.calledWith "event", @blitzOptions.eventPatterns.blitzFail
					done()
			it "should log the blitz results", (done)->
				@sut.run =>
					loggerInstance.info.should.have.been.called
					done()
			it "should log the blitz complete event", (done)->
				@sut.run =>
					loggerInstance.log.should.have.been.calledWith "event", @blitzOptions.eventPatterns.blitzComplete
					done()


	describe "log errors", ->
		beforeEach ->
			@blitzOptions = 
				blitz: '-r ireland http://www.cdsm.co.uk'
				logPath: './some/duff/file.txt'
				eventPatterns: 
					blitzStart: "## Blitz start %s"
					blitzError: "## Blitz error %s"
					blitzComplete: "## Blitz complete"

			sinon.stub( blitzInstance, 'execute').returns rushInstance
			sinon.stub rushInstance, 'on'
			sinon.stub( winstonInstance, 'Logger').returns loggerInstance
			sinon.stub loggerInstance, 'add'

			rushInstance.on.withArgs("error").yields {
				error: 'duff error'
				reason: 'error description'
			}

			@sut = new blitzer( 'myBlitzId@duff.com','some-blitz-id', @blitzOptions)

		afterEach ->
			blitzInstance.execute.restore()
			rushInstance.on.restore()
			winstonInstance.Logger.restore()
			loggerInstance.add.restore()

		it "should log the blitz error", (done)->
			@sut.run ->
				loggerInstance.error.should.have.been.called
				done()

		it "should log the blitz error event", (done)->
			@sut.run =>
				loggerInstance.log.should.have.been.calledWith 'event', @blitzOptions.eventPatterns.blitzError, 'duff error'
				done()

