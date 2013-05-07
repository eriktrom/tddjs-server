


chatRoom =
  addMessage: (user, msgtext, callback) ->
    if !user    then err = new TypeError("user is null")
    if !msgtext then err = new TypeError("Message text is null")
    if !err
      @messages ?= []
      id = @messages.length + 1
      message = {id, user, msgtext}
      @messages.push(message)

    callback(err, message) if typeof callback is "function"

  getMessagesSince: (id, callback) ->
    @messages ?= []
    callback(null, @messages.slice(id))

module.exports = chatRoom