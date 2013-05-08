chai = require("chai")
expect = chai.expect
assert = chai.assert
# chai.Assertion.includeStack = true
Q = require("q")

chatRoom = require("../js/lib/chat_room")

describe "chatRoom", ->

  beforeEach ->
    @room = Object.create(chatRoom)

  describe "#addMessage", ->
    it "should require a username", (done) ->
      @room.addMessage(null, "a message")
      .then null, (err) ->
        assert.isNotNull(err)
        expect(err).to.be.instanceOf(TypeError)
        done()

    it "should require a message", (done) ->
      @room.addMessage("trombom", null)
      .then null, (err) ->
        assert.isNotNull(err)
        expect(err).to.be.instanceOf(TypeError)
        done()

    it "should require a message and a username", (done) ->
      @room.addMessage()
      .then null, (err) ->
        assert.isNotNull(err)
        expect(err).to.be.instanceOf(TypeError)
        done()

    it "should not require a callback", (done) ->
      assert.doesNotThrow =>
        @room.addMessage("erik", "a message")
        done()

    it "should call callback with new msg object", (done) ->
      @room.addMessage("erik", "Some message")
      .then (msg) ->
        assert.isObject(msg)
        assert.isNumber(msg.id)
        assert.equal msg.msgtext, "Some message"
        assert.equal msg.user, "erik"
        done()

    it "should assign unique id's to messages", (done) ->
      user = "erik"

      @room.addMessage(user, "message 1")
      .then (msg1) =>
        @room.addMessage(user, "message 2")
        .then (msg2) ->
          assert.notEqual msg1.id, msg2.id
          done()

    it "(non nested) should assign unique id's to messages", (done) ->
      user = "erik"
      heldMsgs = []
      holdMsg = (msg) -> heldMsgs.push(msg)

      Q.all([
        @room.addMessage(user, "message 1").then(holdMsg),
        @room.addMessage(user, "message 2").then(holdMsg)
      ])
      .done ->
        assert.notEqual heldMsgs[0].id, heldMsgs[1].id
        done()

    it "should add the message to the room's messages array", (done) ->
      @room.addMessage("erik", "message 1")
      .then (msg1) =>
        # checking the @room.messages array directly is frowned upon as it
        # tests implementation details that we don't really care about
        # and makes our test fragile
        assert.deepEqual @room.messages, [msg1]
        @room.addMessage("erik", "message 2")
        .then (msg2) =>
          assert.deepEqual @room.messages, [msg1, msg2]
          done()

    it.skip "should be asynchronous", (done) ->
      heldMsgs = []
      heldMsgsSince = []
      holdMsg = (msg) -> heldMsgs.push(msg)
      holdMsgSince = (msgs) -> heldMsgsSince.push(msgs[0])
      Q.all([
        @room.addMessage("erik", "Some message").then(holdMsg),
        @room.getMessagesSince(heldMsgs.length - 1).then(holdMsgSince)
      ])
      .done ->
        assert.equal heldMsgsSince.length, 0
        assert.equal heldMsgs.length, 0
        done()

    it "should return a promise", (done) ->
      result = @room.addMessage("erik", "A message")

      assert.isObject result
      assert.isFunction result.then
      done()

  describe "#getMessagesSince", ->

    it "should return a promise", (done) ->
      result = @room.getMessagesSince(0)

      assert.isObject result
      assert.isFunction result.then
      done()

    it "should get messages since given id", (done) ->
      user = "erik"
      @room.addMessage(user, "message 1")
      .then (msg1) =>
        @room.addMessage(user, "message 2")
        .then (msg2) =>
          @room.getMessagesSince(msg1.id)
          .then (msgs) ->
            assert.isArray msgs
            assert.deepEqual msgs, [msg2]
            done()

    it "should yield an emtpy array if the messages array does not exist", (done) ->
      @room.getMessagesSince(1)
      .then (msgs) ->
        assert.deepEqual msgs, []
        done()

    it "should yield an empty array if no relevant messages exist", (done) ->
      @room.addMessage("erik", "message 1")
      .then (msg1) =>
        @room.getMessagesSince(msg1.id)
        .then (msgs) ->
          assert.deepEqual msgs, []
          done()