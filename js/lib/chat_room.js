// Generated by CoffeeScript 1.6.2
var Q, chatRoom;

require("./function-bind");

Q = require("q");

chatRoom = {
  addMessage: function(user, msgtext) {
    var deferred;

    deferred = Q.defer();
    process.nextTick((function() {
      var err, id, message;

      if (!user && !msgtext) {
        err = new TypeError("user & msgtext both null");
      }
      if (!err) {
        if (!user) {
          err = new TypeError("user is null");
        }
        if (!msgtext) {
          err = new TypeError("Message text is null");
        }
      }
      if (err) {
        deferred.reject(err);
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
        return deferred.resolve(message);
      }
    }).bind(this));
    return deferred.promise;
  },
  getMessagesSince: function(id) {
    var deferred, msgsSinceId;

    deferred = Q.defer();
    msgsSinceId = (this.messages || []).slice(id);
    deferred.resolve(msgsSinceId);
    return deferred.promise;
  }
};

module.exports = chatRoom;
