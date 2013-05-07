chai = require("chai")
expect = chai.expect
assert = chai.assert
chai.Assertion.includeStack = true

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

  it "should call callback with new data object", (done) ->
    @room.addMessage "erik", "Some message", (err, data) ->
      assert.isObject(data)
      assert.isNumber(data.id)
      assert.equal data.message, "Some message"
      assert.equal data.user, "erik"
      done()

  it "should assign unique id's to messages", (done) ->
    user = "erik"

    @room.addMessage user, "message a", (err, data1) =>
      @room.addMessage user, "message b", (err, data2) ->
        assert.notEqual data1.id, data2.id
        done()