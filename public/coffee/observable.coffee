do ->

  observe = (event, observer) ->
    if typeof observer isnt "function"
      throw new TypeError("observer is not a function")
    _observers(@, event).push(observer)

  hasObserver = (event, observer) ->
    observers = _observers(@, event)
    for obsvr in observers
      return true if obsvr is observer
    false

  notify = (event) ->
    observers = _observers(@, event)
    args = Array::slice.call(arguments, 1)
    for obsvr in observers
      try
        obsvr.apply(@, args)
      catch e
        # its observers responsibility to handle errors properly, pg 233
    return

  tddjs.namespace("util").observable = {
    observe
    hasObserver
    notify
  }


  _observers = (observable, event) ->
    observable.observers = {} unless observable.observers
    observable.observers[event] = [] unless observable.observers[event]
    observable.observers[event]