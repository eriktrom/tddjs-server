http = require('http')
url = require('url')
paperboy = require("node-paperboy")
# TODO: this doesn't work yet, find how to start a node server from a newer book

# require the first module we'll write, dealing w/ request/response logic
crController = require("./chat_room_controller")

# setup chatRoom for the controller
chatRoom = require("./chat_room")
room = Object.create(chatRoom)

# http.createServer accepts a -> which will be attached as the request listener
module.exports = http.createServer (req, res) ->
  # For any request to the /comet URL
  if url.parse(req.url).pathname is "/comet"
    # the server will call the controllers create method, passing it request
    # and response objects
    controller = crController.create(req, res)
    # set the chatRoom, setter injection
    controller.chatRoom = room
    # call a method on the resulting controller corresponding to the HTTP method used.
    controller[req.method.toLowerCase()]()
  else
    delivery = paperboy.deliver("public", req, res)

    delivery.otherwise ->
      res.writeHead 404, "Content-Type": "text/html"
      res.write "<h1>Nothing to see here, move along</h1>"
      res.close