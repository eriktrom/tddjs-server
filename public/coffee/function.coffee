unless Function::bind
  do ->
    slice = Array::slice

    Function::bind = (thisObj) ->
      target = @

      if arguments.length > 1
        args = slice.call(arguments, 1)
        return ->
          allArgs = args
          if arguments.length > 0
            allArgs = args.concat(slice.call(arguments))
          target.apply(thisObj, allArgs)

      return ->
        if arguments.length > 0
          target.apply(thisObj, arguments)
        target.call(thisObj)