chatRoom =
  addMessage: (user, message, callback) ->
    unless user
      callback(new TypeError("user is null"))
    unless message
      callback(new TypeError("message is null"))

module.exports = chatRoom