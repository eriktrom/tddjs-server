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
      @reqDbl = {double: 'req'}
      @resDbl = {double: 'res'}
      @controller = chatRoomController.create(@reqDbl, @resDbl)

    it "inherits from chatRoomController (has the same prototype)", (done) ->
      # assert.ok(controller instanceof chatRoomController)
      # expect(controller).to.be.a.instanceof(chatRoomController)
      assert.ok @controller:: == chatRoomController::
      done()

    it "returns an object with request property === to passed request arg", (done) ->
      assert.deepEqual @controller.request, @reqDbl
      # SAME AS #
      expect(@controller.request).to.eql(@reqDbl)
      done()

    it "returns an object with response property === to passed response arg", (done) ->
      expect(@controller.response).to.deep.equal(@resDbl)
      done()