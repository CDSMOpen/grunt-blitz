grunt = require 'grunt'
blitz = require 'blitz'
gruntblitz = require '../tasks/blitz'

describe 'grunt-blitz', ->
	describe 'testing framework', ->
		it "should be ok", ->
			(true).should.be.ok

		it "should not be ok", ->
			(false).should.not.be.ok

		it "should be ok again", ->
			(true).should.be.ok

		it "should not be ok again", ->
			(false).should.not.be.ok

	describe 'run', ->
		beforeEach ->
			grunt.initConfig {
				blitz:
					options:
						blitzid: 'software@cdsm.co.uk'
						blitzkey: 'duffkey'
			}
			grunt.loadTasks "tasks"

		it "should load the blitz task", ->
			grunt.task.run ["blitz"]
			(true).should.be.ok