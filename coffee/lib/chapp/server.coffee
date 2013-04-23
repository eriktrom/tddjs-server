http = require 'http'
url = require 'url'
crController = require "chapp/chat_room_controller"

module.exports = http.createServer (req, res) ->
  if url.parse(req.url).pathname is "/comet"
    controller = crController.create(req, res)
    controller[req.method.toLowerCase()]()