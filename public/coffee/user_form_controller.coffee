do ->
  return if typeof tddjs is "undefined" ||
            typeof document is "undefined"

  dom = tddjs.namespace("dom")
  util = tddjs.util # can use this b/c observable.coffee defines/loads first
  chat = tddjs.namespace("chat")

  return if !dom || !dom.addEventHandler || !util || !util.observable ||
            !Object.create || !document.getElementsByTagName || !Function::bind


  setView = (element) ->
    element.className = "js-chat"
    dom.addEventHandler element, "submit", @handleSubmit.bind(@)
    @view = element

  handleSubmit = (event) ->
    event.preventDefault()
    if @view
      userName = @view.getElementsByTagName("input")[0].value
      return unless userName
      @view.className = ""
      @model.currentUser = userName
      @notify("user", userName)

  setModel = (@model) ->

  chat.userFormController = tddjs.extend({}, util.observable)
  chat.userFormController.setView = setView
  chat.userFormController.setModel = setModel
  chat.userFormController.handleSubmit = handleSubmit