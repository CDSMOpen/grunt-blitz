grunt = require 'grunt'
hashish = require 'hashish'
SandboxedModule = require 'sandboxed-module'

blitzStub = sinon.stub()

gruntblitz = SandboxedModule.require  '../tasks/blitz',
	requires:
		'blitz': blitzStub
	locals:
		options:
			blitz: '-r ireland http://www.cdsm.co.uk'

describe 'testing framework', ->
	it "should be ok", ->
		(true).should.be.ok

describe 'grunt-blitz', ->
	beforeEach ->
		sinon.spy grunt, 'registerMultiTask'

		gruntblitz(grunt)
		grunt.initConfig
			blitz:
				testBlitz: 
					options:
						blitz: '-r ireland http://www.cdsm.co.uk'
		grunt.task.run 'blitz'

	afterEach ->
		grunt.registerMultiTask.restore()

	it "should register the blitz task", ->
		grunt.registerMultiTask.should.have.been.calledOnce

	it "should create a blitz instance", ->
		grunt.task.run 'blitz'
		blitzStub.should.have.been.calledWithNew

describe 'grunt.initConfig', ->
	beforeEach ->
		grunt.initConfig {
			blitz:
				blitz: '-r ireland http://www.cdsm.co.uk'
		}

	it 'should store config settings', ->
		expect(grunt.config('blitz')).to.exist
