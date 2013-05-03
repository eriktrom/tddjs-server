# mocha -w --compilers coffee:coffee-script
chai = require("chai")
expect = chai.expect
assert = chai.assert
chai.Assertion.includeStack = true


chatRoomController = require('../js/lib/chat_room_controller')

describe "chatRoomController", ->
  it "should be an object", (done) ->
    expect(chatRoomController).to.be.an('object')
    done()

  describe "#create", ->
    it "is a function", (done) ->
      expect(chatRoomController.create).to.be.a('function')
      done()

    beforeEach ->
      @controller = chatRoomController.create(@reqDbl, @resDbl)

    it "inherits from chatRoomController (has the same prototype)", (done) ->
      # assert.ok(controller instanceof chatRoomController)
      # expect(controller).to.be.a.instanceof(chatRoomController)
      assert.ok @controller:: == chatRoomController::
      done()

    context "it returns an object with properties #request & #response", ->

      beforeEach ->
        @reqDbl = {double: 'req'}
        @resDbl = {double: 'res'}

      describe "#request", (done) ->
        it "it is set during creation by request arg given to #create", (done) ->
          assert.deepEqual @controller.request, @reqDbl
          # SAME AS #
          expect(@controller.request).to.eql(@reqDbl)
          done()

      describe "#response", (done) ->
        it "is set during creation by response arg given to #create", (done) ->
          expect(@controller.response).to.deep.equal(@resDbl)
          done()