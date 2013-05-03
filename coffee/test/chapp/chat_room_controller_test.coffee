expect = require('chai').expect
chatRoomController = require('../../lib/chapp/chat_room_controller')

describe "chatRoomController", ->
  it "should be an object", ->
    expect(chatRoomController).to.be.an('object')