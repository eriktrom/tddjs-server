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

    it "should call callback with new msg object (slightly more explicit)", (done) ->
      onFulfilled = (msg) ->
        assert.isObject(msg)
        assert.isNumber(msg.id)
        assert.equal msg.msgtext, "Some message"
        assert.equal msg.user, "erik"
        done()

      @room.addMessage("erik", "Some message")
      .then(onFulfilled)
      # so notice, we aren't actually calling onFulfilled here, we're just passing
      # it to then, which will call it eventually, when deferred.resolve(message)
      # fires a fulfilled event, which happens once its state changes from pending
      # to fulfilled, which happens when deferred.resolve is called for this `then's`
      # event loop. The promise object's value when resolved is the value passed
      # to resolve, in this case, message.
      #
      # So while the last line in addMessage is: deferred.promise, addMessage
      # returns the message it added, just not when it's called, but instead, at
      # some point in the future. When message is finally returned, we'll know
      # about it b/c our onFulfilled callback will be fired and the message will
      # be passed in as the first argument to it. This means when a particular
      # promise is fulfilled, we can do something with the return value `then`,
      # without blocking the thread waiting for that return value in the meantime
      #
      # More than just a performance improvement this is though. It also pushes
      # us to decouple our applicaton logic: it seperates what we want from how
      # to do the work. It helps objects play their tightly defined roles.
      # TODO: ^^ expand upon this
      #
      # Finally, so far, onFulfilled has not itself returned anything. It can
      # however, return a value or throw an exception. Let's talk about returning
      # a value
      #
      # If onFulfilled returns a value, run the Promise Resolution Procedure
      # If onFulfilled in not a function at all and promise is fulfilled, then for:
      # promise2 = promise1.then(onFulfilled)
      # promise2 will be fulfilled with the same value (EASY)
      #
      # (HARDER)
      # The Promise Resolution Procedure
      # assuming onFulfilled is a function that returns a value:
      # promise2 = promise1.then(onFulfilled)
      # AND
      # onFulfilled returns value x
      # AND if x is thenable (if it's not, it is resolved and returns x)
      # then promise2 will adopt the state of x (it will mirror it)
      # AND when x is fulfilled, promise2 will be fulfilled with the same value
      # AND if x is an object or function, let promise2.then be x.then
      #   if x is a function, call promise2 with x as this
      #   SO promise2.then(onFulfilled2) is basically x.then(onFulfilled2)
      #     WHEN onFulfilled2 is called with a value y
      #       IF x === y (object identity), then fulfill promise2 with x
      #       OTHERWISE, run The Promise Resolution Procedure again
      # What the above means is that, you can keep chaining then's and when
      # onFulfilled doesn't return a promise, it is actually fulfilled, emits
      # the fulfilled event, which is then picked up by the then(onFulfilled)
      # of its parent, until all promises are resolved. I think that this part
      # of the spec seems to be aimed at getting different promise libraries
      # working together, notably libs that implemented the spec wrong. Thus, I
      # think this type of promise resolution is only pertinent to promises that
      # are nested/chained in a particular order, and therefore is not applicable
      # to promises that run in parallel, although I am not sure.


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