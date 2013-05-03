module.exports = (returnValue) ->
  stub = ->
    stub.called = true
    stub.args = arguments
    stub.thisArg = @
    returnValue
  stub.called = false
  stub