require("./function-bind")
Q = require("q")
EventEmitter = require("events").EventEmitter

chatRoom = Object.create EventEmitter::

chatRoom.addMessage = (user, msgtext) ->
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

  ).bind(@)
  deferred.promise

chatRoom.getMessagesSince = (id) ->
  deferred = Q.defer()
  process.nextTick (->
    deferred.resolve( (@messages || []).slice(id) )
  ).bind(@)
  deferred.promise

module.exports = chatRoom