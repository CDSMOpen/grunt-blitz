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