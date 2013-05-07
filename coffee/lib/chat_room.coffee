


chatRoom =
  addMessage: (user, msgtext, callback) ->
    if !user    then err = new TypeError("user is null")
    if !msgtext then err = new TypeError("Message text is null")
    if !err
      @id ?= 1
      message = {id: @id++, user: user, msgtext: msgtext}
      @messages ?= []
      @messages.push(message)

    callback(err, message) if typeof callback is "function"

  getMessagesSince: (id, callback) ->
    callback(null, @messages[id..])

module.exports = chatRoom