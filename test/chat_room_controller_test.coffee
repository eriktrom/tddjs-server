# mocha -w --compilers coffee:coffee-script
chai = require("chai")
expect = chai.expect
assert = chai.assert
Q = require("q")

chatRoomController = require('../js/lib/chat_room_controller')
EventEmitter = require("events").EventEmitter
stub = require("../js/lib/stub")

controllerSetUp = ->
  # stub the request as an event emitter
  @reqDbl = new EventEmitter()
  # set the headers we'll be receiving from comet client by default
  @reqDbl.headers = {"x-access-token": ""}
  # stub the response
  @resDbl = {writeHead: stub(), end: stub()}
  # create real controller, passing it reqDbl & resDbl
  @controller = chatRoomController.create(@reqDbl, @resDbl)

  # stub methods on chatRoom to return promises we can control in our tests here
  @addMessageDeferredDbl = Q.defer()
  @waitForMessagesSinceDeferredDbl = Q.defer()
  @controller.chatRoom =
    addMessage: stub(@addMessageDeferredDbl.promise)
    waitForMessagesSince: stub(@waitForMessagesSinceDeferredDbl.promise)

  # stub out some data to be returned by JSON.parse
  @dataDbl = {data: {user: "erik", message: "sup"}}
  # fake the incoming request
  @sendRequest = (data) ->
    # tddjs.ajax tools build in prev chpts currently only support URL encoded
    # data, so lets encode it to fit
    strDbl = encodeURI(JSON.stringify(@dataDbl))
    # emit simple URL encoded JSON string in two chunks, then emit end event
    @reqDbl.emit("data", strDbl.substring(0, strDbl.length/2))
    @reqDbl.emit("data", strDbl.substring(strDbl.length/2))
    @reqDbl.emit("end")

  # hold onto me!
  @jsonParse = JSON.parse

controllerTearDown = ->
  JSON.parse = @jsonParse

describe "chatRoomController", ->
  it "should be an object", (done) ->
    expect(chatRoomController).to.be.an('object')
    done()
  it "inherits from chatRoomController (has the same prototype)", ->
    controller = chatRoomController.create({}, {})
    # assert.ok(controller instanceof chatRoomController)
    # expect(controller).to.be.a.instanceof(chatRoomController)
    assert.ok controller:: == chatRoomController::

  beforeEach -> controllerSetUp.call(@)
  afterEach -> controllerTearDown.call(@)

  describe "#create", ->
    it "is a function", ->
      expect(chatRoomController.create).to.be.a('function')

    # TODO: clean me up
    context "it returns an object with properties #request & #response", ->
      describe "#request", (done) ->
        it "it is set during creation by request arg given to #create", (done) ->
          assert.deepEqual @controller.request, @reqDbl
          # SAME AS #
          expect(@controller.request).to.eql(@reqDbl)
          done()

      describe "#response", (done) ->
        it "is set during creation by response arg given to #create", (done) ->
          expect(@controller.response).to.deep.equal(@resDbl)
          done()

  describe "#post", ->

    it "should retrieve the request body by concatenating its evented chunks", (done) ->
      # stub JSON.parse to return @dataDbl and spy on calls & their arguments
      JSON.parse = stub(@dataDbl)

      # when i call post on the controller
      @controller.post()
      @sendRequest(@dataDbl)

      # then JSON.parse should have been called with stubbed data stub data
      assert.deepEqual JSON.parse.args[0], JSON.stringify(@dataDbl)
      done()

    it "adds the message from the request body to the chat room", (done) ->
      @controller.post()
      @sendRequest(@dataDbl)

      # controller should have called chatRoom.addMessage with the correct args
      assert.ok @controller.chatRoom.addMessage.called
      args = @controller.chatRoom.addMessage.args
      assert.deepEqual args[0], @dataDbl.data.user
      assert.deepEqual args[1], @dataDbl.data.message
      done()

    it "should call respond immediately when #post is resolved", (done) ->
      @controller.post()
      @sendRequest(@dataDbl)
      @addMessageDeferredDbl.resolve {}
      @controller.respond = stub()

      process.nextTick =>
        Q.delay(0)
        .then =>
          assert.ok @controller.respond.called
          done()
        .done()

    it "should not respond immediately", (done) ->
      @controller.post()
      @sendRequest(@dataDbl)
      @controller.respond = stub()

      assert.ok !!!@controller.respond.called
      done()

  describe "#get", ->

    it "should return all available messages on for first incoming request", (done) ->
      subject = @controller.chatRoom.waitForMessagesSince = stub()

      @controller.get()

      assert.ok subject.called
      expect(subject.args[0]).to.eq "0"
      done()

    it "should wait for messages since x-access-token", (done) ->
      @reqDbl.headers = {"x-access-token": "2"}
      subject = @controller.chatRoom.waitForMessagesSince = stub()

      @controller.get()

      assert.ok subject.called
      expect(subject.args[0]).to.eq "2"
      done()

  describe "#respond", ->

    it "should write status code", (done) ->
      @controller.respond(201)

      expect(@resDbl.writeHead.called).to.be.true
      expect(@resDbl.writeHead.args[0]).to.eq 201
      done()

    it "should close connection", (done) ->
      @controller.respond(201)

      expect(@resDbl.end.called).to.be.true
      done()
