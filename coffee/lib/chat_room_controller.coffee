chatRoomController =
  create: (request, response) ->
    Object.create @,
      request: {value: request}
      response: {value: response}

module.exports = chatRoomController