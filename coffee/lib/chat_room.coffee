id = 0


chatRoom =
  addMessage: (user, msgtext, callback) ->
    @messages ?= []
    if !user    then err = new TypeError("user is null")
    if !msgtext then err = new TypeError("Message text is null")
    if !err
      message = {id: id++, user: user, msgtext: msgtext}
      @messages.push(message)

    callback(err, message) if typeof callback is "function"

  getMessagesSince: (id, callback) ->
    err = null
    callback(err, @messages)

module.exports = chatRoom