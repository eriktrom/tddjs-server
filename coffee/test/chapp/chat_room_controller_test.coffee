testCase = require("nodeunit").testCase
chatRoomController = require('../../lib/chapp/chat_room_controller')

exports.testchatRoomController = (test) ->
  test.isNotNull(chatRoomController)
  test.isFunction(chatRoomController.create)
  test.done()
