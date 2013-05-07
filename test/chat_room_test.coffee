chai = require("chai")
expect = chai.expect
assert = chai.assert
# chai.Assertion.includeStack = true

chatRoom = require("../js/lib/chat_room")

describe "chatRoom#addMessage", ->
  beforeEach ->
    @room = Object.create(chatRoom)

  it "should require a username", (done) ->
    @room.addMessage null, "a message", (err) =>
      assert.isNotNull(err)
      assert.ok err.constructor is TypeError
      # SAME AS #
      assert.ok err instanceof TypeError
      done()

  it "should require a message", (done) ->
    @room.addMessage "trombom", null, (err) =>
      assert.isNotNull(err)
      assert.ok err instanceof TypeError
      done()

  it "should not require a callback", (done) ->
    assert.doesNotThrow =>
      @room.addMessage()
      done()

  it "should call callback with new msg object", (done) ->
    @room.addMessage "erik", "Some message", (e, msg) ->
      assert.isObject(msg)
      assert.isNumber(msg.id)
      assert.equal msg.msgtext, "Some message"
      assert.equal msg.user, "erik"
      done()

  it "should assign unique id's to messages", (done) ->
    user = "erik"

    @room.addMessage user, "message 1", (e, msg1) =>
      @room.addMessage user, "message 2", (e, msg2) ->
        assert.notEqual msg1.id, msg2.id
        done()

  it "should add the message to the room's messages array", (done) ->
    @room.addMessage "erik", "message 1", (e, msg1) =>
      assert.deepEqual @room.messages, [msg1]
      @room.addMessage "erik", "message 2", (e, msg2) =>
        assert.deepEqual @room.messages, [msg1, msg2]
        done()


describe "chatRoom#getMessagesSince", ->

  it "should get messages since given id", (done) ->
    room = Object.create(chatRoom)
    user = "erik"

    room.addMessage user, "message 1", (e, msg1) ->
      room.addMessage user, "message 2", (e, msg2) ->
        room.getMessagesSince msg1.id, (e, msgs) ->
          assert.isArray msgs
          assert.deepEqual msgs, [msg2]
          done()