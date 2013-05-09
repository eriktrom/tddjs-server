Q = require("q")
EventEmitter = require("events").EventEmitter

chatRoom = Object.create EventEmitter::

chatRoom.addMessage = (user, msgtext) ->
  deferred = Q.defer()
  process.nextTick =>
    err = chatRoomPrivateMethods.addMessageErr(user, msgtext)
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
  @getMessagesSince(id)

# where do I put private methods? non-exported? non-tested helpers?
chatRoomPrivateMethods = Object.create
chatRoomPrivateMethods.addMessageErr = (user, msgtext) ->
  if !user && !msgtext then err = new TypeError("user & msgtext both null")
  if !err
    if !user           then err = new TypeError("user is null")
    if !msgtext        then err = new TypeError("Message text is null")
  err

module.exports = chatRoom


