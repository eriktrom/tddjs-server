require("./function-bind")

chatRoom =
  addMessage: (user, msgtext, callback) ->
    process.nextTick (->
      err = new TypeError("user is null") if !user
      err = new TypeError("Message text is null") if !msgtext
      if !err
        @messages ||= []
        id = @messages.length + 1
        message = {id, user, msgtext}
        @messages.push(message)

      callback(err, message) if typeof callback is "function"
    ).bind(@)

  getMessagesSince: (id, callback) ->
    callback(null, (@messages || []).slice(id))

module.exports = chatRoom