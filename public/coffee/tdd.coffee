tddjs = do ->
  namespace = (string) ->
    object = @
    levels = string.split(".")

    for level in levels
      if typeof object[level] is "undefined"
        object[level] = {}
      object = object[level]
    object

  {namespace}

tddjs.isOwnProperty = do ->
  hasOwn = Object::hasOwnProperty
  if typeof hasOwn is "function"
    return (object, property) ->
      hasOwn.call(object, property)

  # the above function has a return in front of it b/c without it
  # addition of the following function removes the implicit return
  # even though its outside the if statement, thus to keep unknown
  # future changes from braking something, i think I should follow
  # this convention - any time your return ->, put return ->
  # ->

tddjs.extend = do ->
  extend = (target, source) ->
    target = target || {}
    return target if !source
    tddjs.each source, (prop, val) ->
      target[prop] = val
    target
  extend

`
tddjs.each = (function () {
  // Returns an array of properties that are not exposed
  // in a for-in loop
  function unEnumerated(object, properties) {
    var length = properties.length;

    for (var i = 0; i < length; i++) {
      object[properties[i]] = true;
    }

    var enumerated = length;

    for (var prop in object) {
      if (tddjs.isOwnProperty(object, prop)) {
        enumerated -= 1;
        object[prop] = false;
      }
    }

    if (!enumerated) {
      return;
    }

    var needsFix = [];

    for (i = 0; i < length; i++) {
      if (object[properties[i]]) {
        needsFix.push(properties[i]);
      }
    }

    return needsFix;
  }

  var oFixes = unEnumerated({},
    ["toString", "toLocaleString", "valueOf",
     "hasOwnProperty", "isPrototypeOf",
     "constructor", "propertyIsEnumerable"]);

  var fFixes = unEnumerated(
    function () {}, ["call", "apply", "prototype"]);

  if (fFixes && oFixes) {
    fFixes = oFixes.concat(fFixes);
  }

  var needsFix = { "object": oFixes, "function": fFixes };

  return function (object, callback) {
    if (typeof callback != "function") {
      throw new TypeError("callback is not a function");
    }

    // Normal loop, should expose all enumerable properties
    // in conforming browsers
    for (var prop in object) {
      if (tddjs.isOwnProperty(object, prop)) {
        callback(prop, object[prop]);
      }
    }

    // Loop additional properties in non-conforming browsers
    var fixes = needsFix[typeof object];

    if (fixes) {
      var property;

      for (var i = 0, l = fixes.length; i < l; i++) {
        property = fixes[i];

        if (tddjs.isOwnProperty(object, property)) {
          callback(property, object[property]);
        }
      }
    }
  };
}());

tddjs.isHostMethod = (function () {
  function isHostMethod(object, property) {
    var type = typeof object[property];

    return type == "function" ||
           (type == "object" && !!object[property]) ||
           type == "unknown";
  }

  return isHostMethod;
}());
`
tddjs.isLocal = do ->
  isLocal = ->
    !!(window.location && window.location.protocol.indexOf("file:") is 0)
  isLocal

`
tddjs.isEventSupported = (function () {
  var TAGNAMES = {
    select: "input",
    change: "input",
    submit: "form",
    reset: "form",
    error: "img",
    load: "img",
    abort: "img"
  };

  function isEventSupported(eventName) {
    var tagName = TAGNAMES[eventName];
    var el = document.createElement(tagName || "div");
    eventName = "on" + eventName;
    var isSupported = (eventName in el);

    if (!isSupported) {
      el.setAttribute(eventName, "return;");
      isSupported = typeof el[eventName] == "function";
    }

    el = null;

    return isSupported;
  }

  return isEventSupported;
}());
`

do ->
  dom = tddjs.namespace("dom")
  _addEventHandler = null

  return unless Function::call

  normalizeEvent = (event) ->
    event.preventDefault = ->
      event.returnValue = false
    event.target = event.srcElement
    event

  if tddjs.isHostMethod(document, "addEventListener")
    _addEventHandler = (element, event, listener) ->
      element.addEventListener(event, listener, false)
  else if tddjs.isHostMethod(document, "attachEvent")
    _addEventHandler = (element, event, listener) ->
      element.attachEvent "on#{event}", ->
        event = normalizeEvent(window.event)
        listener.call(element, event)
        event.returnValue
  else return

  mouseenter = (el, listener) ->
    current = null
    _addEventHandler el, "mouseover", (event) ->
      if current isnt el
        current = el
        listener.call(el, event)

    _addEventHandler el, "mouseout", (event) ->
      target = event.relatedTarget || event.toElement
      try
        if target && !target.nodeName
          target = target.parentNode
      catch e
        return
      if el isnt target && !dom.contains(el, target)
        current = null

  custom = dom.customEvent = {}

  if !tddjs.isEventSupported("mouseenter") &&
      tddjs.isEventSupported("mouseover") &&
      tddjs.isEventSupported("mouseout")
    custom.mouseenter = mouseenter

  dom.supportsEvent = (event) ->
    tddjs.isEventSupported(event) || !!custom[event]

  addEventHandler = (element, event, listener) ->
    if dom.customEvents && dom.customEvents[event]
      dom.customEvents[event](element, listener)
    _addEventHandler(element, event, listener)

  dom.addEventHandler = addEventHandler

