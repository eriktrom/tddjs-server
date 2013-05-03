sys = require("sys")

chatRoom =
  addMessage: (user, message) ->
    sys.puts("#{user}:#{message}")

module.exports = chatRoom