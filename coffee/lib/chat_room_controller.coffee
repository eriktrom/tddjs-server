chatRoomController =
  create: (request, response) ->
    Object.create @,
      request: {value: request}
      response: {value: response}

  post: ->
    body = ""

    @request.addListener "data", (chunk) ->
      body += chunk

    @request.addListener "end", =>
      data = JSON.parse(decodeURI(body)).data
      @chatRoom.addMessage(data.user, data.message)
      .then =>
        @response.writeHead(201)
        @response.end()
      .done()

  get: ->
    if @request.headers["x-access-token"] is ""
      @chatRoom.waitForMessagesSince(0)

module.exports = chatRoomController