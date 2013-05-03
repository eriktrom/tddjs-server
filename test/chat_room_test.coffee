chai = require("chai")
expect = chai.expect
assert = chai.assert
chai.Assertion.includeStack = true

chatRoom = require("../js/lib/chat_room")

describe "chatRoom.addMessage", ->
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