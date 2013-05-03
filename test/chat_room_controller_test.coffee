# mocha -w --compilers coffee:coffee-script
chai = require("chai")
expect = chai.expect
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