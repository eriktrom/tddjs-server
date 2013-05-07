// Generated by CoffeeScript 1.6.2
var Q, chatRoom;

require("./function-bind");

Q = require("q");

chatRoom = {
  addMessage: function(user, msgtext, callback) {
    var deferred;

    deferred = Q.defer();
    process.nextTick((function() {
      var err, id, message;

      if (!user) {
        err = new TypeError("user is null");
      }
      if (!msgtext) {
        err = new TypeError("Message text is null");
      }
      if (!err) {
        this.messages || (this.messages = []);
        id = this.messages.length + 1;
        message = {
          id: id,
          user: user,
          msgtext: msgtext
        };
        this.messages.push(message);
      }
      if (typeof callback === "function") {
        return callback(err, message);
      }
    }).bind(this));
    return deferred.promise;
  },
  getMessagesSince: function(id, callback) {
    return callback(null, (this.messages || []).slice(id));
  }
};

module.exports = chatRoom;
