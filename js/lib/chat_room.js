// Generated by CoffeeScript 1.6.2
var chatRoom;

chatRoom = {
  addMessage: function(user, message, callback) {
    if (!user) {
      return callback(new TypeError("user is null"));
    }
  }
};

module.exports = chatRoom;
