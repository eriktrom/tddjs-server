chatRoom =
  addMessage: (user, message, callback) ->
    if !user
      callback(new TypeError("user is null"))

module.exports = chatRoom