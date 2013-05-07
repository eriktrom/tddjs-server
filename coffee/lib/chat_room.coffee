require("./function-bind")
Q = require('q')

chatRoom =
  addMessage: (user, msgtext, callback) ->
    process.nextTick (->
      if !user    then err = new TypeError("user is null")
      if !msgtext then err = new TypeError("Message text is null")
      if !err
        @messages ?= []
        id = @messages.length + 1
        message = {id, user, msgtext}
        @messages.push(message)

      callback(err, message) if typeof callback is "function"
    ).bind(@)

    Q.defer().promise

  getMessagesSince: (id, callback) ->
    @messages ?= []
    callback(null, @messages.slice(id))

module.exports = chatRoom