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
        @respond(201)
      .done()

  get: ->
    id = @request.headers["x-access-token"] || "0"
    @chatRoom.waitForMessagesSince(id)

  respond: (status) ->
    @response.writeHead(status)
    @response.end()

module.exports = chatRoomController