Q = require("q")
EventEmitter = require("events").EventEmitter

chatRoom = Object.create EventEmitter::

chatRoom.addMessage = (user, msgtext) ->
  deferred = Q.defer()
  process.nextTick =>
    err = addMessageErr(user, msgtext)
    if err then deferred.reject(err)
    else
      @messages ||= []
      id = @messages.length + 1
      message = {id, user, msgtext}
      @messages.push(message)
      @emit "message", message
      deferred.resolve(message)
  deferred.promise

chatRoom.getMessagesSince = (id) ->
  deferred = Q.defer()
  process.nextTick =>
    deferred.resolve((@messages || []).slice(id))
  deferred.promise

chatRoom.waitForMessagesSince = (id) ->
  deferred = Q.defer()
  @getMessagesSince(id)
  .then (msgs) =>
    if msgs.length > 0 then deferred.resolve(msgs)
    else
      @addListener "message", (message) -> deferred.resolve([message])
  .done()
  deferred.promise

module.exports = chatRoom


addMessageErr = (user, msgtext) ->
  if !user && !msgtext then err = new TypeError("user & msgtext both null")
  if !err
    if !user           then err = new TypeError("user is null")
    if !msgtext        then err = new TypeError("Message text is null")
  err
# ^^ any functions defined within the scope of this file are not public in node
# perhaps my own convention for private methods then should be two spaces after
# module.exports, then private methods