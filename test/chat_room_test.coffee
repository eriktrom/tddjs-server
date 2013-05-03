chai = require("chai")
expect = chai.expect
assert = chai.assert
chai.Assertion.includeStack = true

chatRoom = require("../js/lib/chat_room")

describe "chatRoom.addMessage", ->
  it "should require a username", (done) ->
    room = Object.create(chatRoom)

    room.addMessage null, "a message", (err) ->
      assert.isNotNull(err)
      assert.ok err.constructor is TypeError
      # SAME AS #
      assert.ok err instanceof TypeError
      done()
