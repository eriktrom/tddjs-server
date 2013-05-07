require("./function-bind")
Q = require('q')

chatRoom =
  addMessage: (user, msgtext, callback) ->
    deferred = Q.defer()
    process.nextTick (->
      err = new TypeError("user is null") if !user
      err = new TypeError("Message text is null") if !msgtext
      if err
        deferred.reject(err, true)

      if !err
        @messages ?= []
        id = @messages.length + 1
        message = {id, user, msgtext}
        @messages.push(message)

      callback(err, message) if typeof callback is "function"
    ).bind(@)
    deferred.promise


  getMessagesSince: (id, callback) ->
    @messages ?= []
    callback(null, @messages.slice(id))

module.exports = chatRoom