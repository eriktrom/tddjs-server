require("./function-bind")
Q = require("q")

chatRoom =
  addMessage: (user, msgtext, callback) ->
    deferred = Q.defer()
    process.nextTick (->
      if !user && !msgtext then err = new TypeError("user & msgtext both null")
      if !err
        if !user           then err = new TypeError("user is null")
        if !msgtext        then err = new TypeError("Message text is null")
      if err
        deferred.reject(err)
        # since we are not passing a callback, no action will happen during
        # the next turn of the event loop, just some variables will be set, etc
        # but we'd have no way of knowing, no access to the state inside this
        # method anyway. Sure, we could check the @messages array, but that's
        # like prying into an object and grabbing its instance variables in
        # ruby -- bad practice, as its tests the internal implementation details
        # not the behavior or external api
        #
        # thus, at first, we used a callback, and passed it an error which we
        # captured by err, and we also pass it a message, the message we just
        # added to the @messages array. This works, but if this method
        # called another method that also took a callback, and so on, things get
        # hard to reason about. Plus, in order to test that this is even
        # asynchronous, at least without promises, we have to check something
        # like the messages array, or keep track of what id of the last message
        # and then use another method for checking the messages
        # array(eg, getMessagesSince)
        #
        # Thus, testing async code is hard. To make it easier, we can use promises
        #
        # We can place synchronous looking tests inside of then calls to test
        # the state of the env or to test that a spy was called or whatever
        # IN THE NEXT TURN OF THE EVENT LOOP - b/c callbacks given to .then
        # are never called in this current turn, always in the next turn, thus
        # any assertions we put inside them are guaranteed to be testing code
        # run inside of process.nextTick after the next tick. Make sense?

      if !err
        @messages ||= []
        id = @messages.length + 1
        message = {id, user, msgtext}
        @messages.push(message)

      callback(err, message) if typeof callback is "function"
    ).bind(@)
    deferred.promise

  getMessagesSince: (id, callback) ->
    callback(null, (@messages || []).slice(id))

module.exports = chatRoom