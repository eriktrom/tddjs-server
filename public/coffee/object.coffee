unless Object.create
  do ->
    F = ->
    Object.create = (object) ->
      F:: = object
      new F()