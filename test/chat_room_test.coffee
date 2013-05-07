chai = require("chai")
expect = chai.expect
assert = chai.assert
# chai.Assertion.includeStack = true
Q = require('q')
stub = require('../js/lib/stub')

chatRoom = require("../js/lib/chat_room")

describe "chatRoom", ->

  it "should be an event emmitter", (done) ->
    assert.isFunction chatRoom.addListener
    assert.isFunction chatRoom.emit
    done()

  beforeEach ->
    @room = Object.create(chatRoom)

  describe "#addMessage", ->
    it "should require a username", (done) ->
      promise = @room.addMessage null, "a message"


      promise.then ->
        #no onFulfilled handler here
      ,
      # promise's reason is first arg of onRejected, aka, onRejected(reason)
      # so err = reason for error
      (err) ->
        assert.isNotNull(err)
        assert.ok err.constructor is TypeError
        # SAME AS #
        assert.ok err instanceof TypeError
        done()

    it "should require a message", (done) ->
      promise = @room.addMessage "trombom", null
      promise.fail (err) -> # Notice the diff from previous, use of fail only
        assert.isNotNull(err)
        assert.ok err instanceof TypeError
        done()

    it.skip "should not require a callback", (done) ->
      # TODO: do something with promises here
      assert.doesNotThrow =>
        @room.addMessage()
        done()

    # TODO: understand how this works
    it "should call callback with new msg object", (done) ->
      @room.addMessage("erik", "Some message")
      # promise's value is first arg of onFulfilled
      # so msg = value of promise
      .then (msg) ->
        assert.isObject(msg)
        assert.isNumber(msg.id)
        assert.equal msg.msgtext, "Some message"
        assert.equal msg.user, "erik"
        done()

    it.skip "should take callback with new msg object old school way", (done) ->
      @room.addMessage "erik", "Some message", (e, msg) ->
        assert.isObject(msg)
        assert.isNumber(msg.id)
        assert.equal msg.msgtext, "Some message"
        assert.equal msg.user, "erik"
        done()

    it "should assign unique id's to messages(flat .all version)", (done) ->
      user = "erik"

      room = @room
      messages = []
      collect = (msg) -> messages.push(msg)

      Q.all([
        room.addMessage("erik", "message 1").then(collect),
        room.addMessage("erik", "message 2").then(collect)
      ])
      .then ->
        assert.notEqual(messages[0].id, messages[1].id)
        done()
      .done()

    it "should assign unique id's to messages(nested version)", (done) ->
      user = "erik"

      @room.addMessage(user, "message 1").then (msg1) =>
        @room.addMessage(user, "message 2").then (msg2) ->
          assert.notEqual msg1.id, msg2.id
          done()

    it "should add the message to the room's messages array", (done) ->
      @room.addMessage("erik", "message 1").then (msg1) =>
        # checking the @room.messages array directly is frowned upon as it
        # tests implementation details that we don't really care about
        # and makes our test fragile
        assert.deepEqual @room.messages, [msg1]
        @room.addMessage("erik", "message 2").then (msg2) =>
          assert.deepEqual @room.messages, [msg1, msg2]
          done()

    it.skip "should be asynchronous", (done) ->
      id = null
      room = @room
      messages = []

      room.addMessage("erik", "Some message")
      .then (msg) ->
        id = msg.id
        messages.push(msg)

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
        room.getMessagesSince(id - 1)
      .then (msgs) ->
        assert.equal msgs.length, 0
        done()
      .done()

    it "should return a promise", (done) ->
      result = @room.addMessage "erik", "message"

      assert.isObject(result)
      assert.isFunction(result.then)
      done()

    it "should emit 'message' event", (done) ->
      message = "oops"
      @room.addListener "message", (m) ->
        message = m

      @room.addMessage("erik", "msg")
      .then (m) ->
        assert.strictEqual m, message
        assert.notStrictEqual message, "oops"
        done()
      .done()

  describe "#getMessagesSince", ->
    it "should return a promise", (done) ->
      result = @room.getMessagesSince(0)

      assert.isObject(result)
      assert.isFunction result.then
      done()

    it "should get messages since given id (nested version)", (done) ->
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

    it "should get messages since given id (flat version)", (done) ->
      user = "erik"
      messages = []


      Q.all([
        @room.addMessage(user, "message 1").then((msg) -> messages.push(msg)),
        @room.addMessage(user, "message 2").then((msg) -> messages.push(msg))
      ])
      .then (msgs) =>
        @room.getMessagesSince(messages[0].id)
        .then (msgs) ->
          assert.isArray msgs
          assert.deepEqual msgs, [messages[1]]
          done()
      .done()

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

  describe "#waitForMessagesSince", ->
    it "should yield any existing messages", (done) ->
      deferred = Q.defer()
      deferred.resolve([{id: 43}])
      @room.getMessagesSince = stub(deferred.promise)

      @room.waitForMessagesSince(42)
      .then (m) ->
        assert.strictEqual m, [{id: 43}]
        done()
      .done()