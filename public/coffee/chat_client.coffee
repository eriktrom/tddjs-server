do ->
  if typeof tddjs is "undefined" || typeof document is "undefined" ||
      !document.getElementById || !Object.create ||
      !tddjs.namespace("chat").userFormController
    alert("Browser is not supported")
    return

  chat = tddjs.chat
  model = {}
  userForm = document.getElementById("userForm")
  userController = Object.create(chat.userFormController)
  userController.setModel(model)
  userController.setView(userForm)

  userController.observe "user", (user) ->
    alert("Welcome, #{user}")