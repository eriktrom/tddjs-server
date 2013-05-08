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

      if !err
        @messages ||= []
        id = @messages.length + 1
        message = {id, user, msgtext}
        @messages.push(message)
        deferred.resolve(message)

      callback(err, message) if typeof callback is "function"
    ).bind(@)
    deferred.promise

  getMessagesSince: (id, callback) ->
    callback(null, (@messages || []).slice(id))

module.exports = chatRoom