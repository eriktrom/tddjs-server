# mocha -w --compilers coffee:coffee-script
chai = require("chai")
expect = chai.expect
assert = chai.assert
chai.Assertion.includeStack = true


chatRoomController = require('../js/lib/chat_room_controller')
EventEmitter = require("events").EventEmitter
stub = require("../js/lib/stub")

controllerSetUp = ->
  # stub the request and response (request is an event emitter)
  reqDbl = @reqDbl = new EventEmitter()
  resDbl = @resDbl = {writeHead: stub(), end: stub()}
  # create real controller, passing it reqDbl & resDbl
  @controller = chatRoomController.create(reqDbl, resDbl)
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

    beforeEach ->
      # stub out some data to be returned by JSON.parse
      @dataDbl = {data: {user: "erik", message: "sup"}}
      @controller.chatRoom = {addMessage: stub()}
      @sendRequest = (data) ->
        # tddjs.ajax tools build in prev chpts currently only support URL encoded
        # data, so lets encode it to fit
        strDbl = encodeURI(JSON.stringify(@dataDbl))
        # emit simple URL encoded JSON string in two chunks, then emit end event
        @reqDbl.emit("data", strDbl.substring(0, strDbl.length/2))
        @reqDbl.emit("data", strDbl.substring(strDbl.length/2))
        @reqDbl.emit("end")

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

    it "should write the status http header", (done) ->
      @controller.post()
      @sendRequest(@dataDbl)

      assert.ok @resDbl.writeHead.called
      assert.deepEqual @resDbl.writeHead.args[0], 201
      done()

    it "should close the connection", (done) ->
      @controller.post()
      @sendRequest(@dataDbl)

      assert.ok @resDbl.end.called
      done()
