chai = require("chai")
expect = chai.expect
assert = chai.assert
# chai.Assertion.includeStack = true

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

    it "should not require a callback", (done) ->
      assert.doesNotThrow =>
        @room.addMessage("erik", "a message")
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
        # checking the @room.messages array directly is frowned upon as it
        # tests implementation details that we don't really care about
        # and makes our test fragile
        assert.deepEqual @room.messages, [msg1]
        @room.addMessage "erik", "message 2", (e, msg2) =>
          assert.deepEqual @room.messages, [msg1, msg2]
          done()

    it "should be asynchronous", (done) ->
      id = null
      @room.addMessage "erik", "Some message", (err, msg) ->
        id = msg.id

      # here, we grab all messages since before the previous one was added
      # thus, in a synchronous world, msgs.length should eq 1, but in an
      # asynchronous world, it should still equal 0 b/c if addMessage were
      # async, it would not run it's callback until the next turn of the event
      # loop, and thus, until after done() is called. this test therefore proves
      # that the messages array is still emtpy and that therefore its async
      #
      # this test falls under the same category as the previous - namely, it
      # tests implementation details. it should be removed, we'll use promises
      # instead
      @room.getMessagesSince id - 1, (err, msgs) ->
        assert.equal msgs.length, 0
        done()

    it "should return a promise", (done) ->
      result = @room.addMessage("erik", "A message")

      assert.isObject result
      assert.isFunction result.then
      done()

  describe "#getMessagesSince", ->
    it "should get messages since given id", (done) ->
      user = "erik"
      @room.addMessage user, "message 1", (e, msg1) =>
        @room.addMessage user, "message 2", (e, msg2) =>
          @room.getMessagesSince msg1.id, (e, msgs) ->
            assert.isArray msgs
            assert.deepEqual msgs, [msg2]
            done()

    it "should yield an emtpy array if the messages array does not exist", (done) ->
      @room.getMessagesSince 1, (e, msgs) ->
        assert.deepEqual msgs, []
        done()

    it "should yield an empty array if no relevant messages exist", (done) ->
      @room.addMessage "erik", "message 1", (e, msg1) =>
        @room.getMessagesSince msg1.id, (e, msgs) ->
          assert.deepEqual msgs, []
          done()