require("./function-bind")
Q = require('q')
EventEmitter = require('events').EventEmitter

chatRoom = Object.create EventEmitter::,

  addMessage:
    value: (user, msgtext) ->
      deferred = Q.defer()
      process.nextTick (->
        # TODO: I want create an errors array and pass that to deferred.reject
        # how do I do that?
        err = new TypeError("user is null") if !user
        err = new TypeError("Message text is null") if !msgtext
        if err
          deferred.reject(err)

        if !err
          @messages ?= []
          id = @messages.length + 1
          message = {id, user, msgtext}
          @messages.push(message)
          @emit("message", message)
          deferred.resolve(message)

        # if typeof callback is "function"
        #   callback(err, message)
      ).bind(@)
      deferred.promise


  getMessagesSince:
    value: (id, callback) ->
      deferred = Q.defer()
      @messages ?= []
      process.nextTick (->
        deferred.resolve(@messages.slice(id))
      ).bind(@)
      deferred.promise

module.exports = chatRoom