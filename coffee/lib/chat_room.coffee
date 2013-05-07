chatRoom =
  addMessage: (user, message, callback) ->
    err = new TypeError("user is null") if !user
    err = new TypeError("message is null") if !message

    if !err
      data = {id: 1, user: user, message: message}

    callback(err, data) if typeof callback is "function"




module.exports = chatRoom