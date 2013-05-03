chatRoom =
  addMessage: (user, message, callback) ->
    err = new TypeError("user is null") if !user
    err = new TypeError("message is null") if !message
    callback(err) if typeof callback is "function"


module.exports = chatRoom