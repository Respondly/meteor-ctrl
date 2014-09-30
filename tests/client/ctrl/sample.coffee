Ctrl.define
  'callbacksTest':
    init: ->
      @initWasCalled = true
      @modelCount = 0
    ready: -> @createdWasCalled = true
    destroyed: -> @destroyedWasCalled = true
    model: ->
      @modelCount += 1
      { name:'my-model' }


# ----------------------------------------------------------------------


Ctrl.define
  'apiTest':
    api:
      myProp: (value) -> @prop 'myProp', value, default:123
      myDefault: -> @defaultValue('myDefault', 'foo')
      myMethod: -> { self: @ }
      children: -> 'my-children'


# ----------------------------------------------------------------------


Ctrl.define
  'foo':
    api:
      text: (value) -> @prop 'text', value

    helpers:
      text: -> "#{ @api.text() }:#{ @uid }"


# ----------------------------------------------------------------------


Ctrl.define
  'deep':
    helpers:
      childData: -> { foo:123 }

  'deep-child': {}


# ----------------------------------------------------------------------


Ctrl.define
  'autorun':
    ready: ->
      @runCount = 0
      @autorun =>
        value = Session.get('reactive-value')
        @runCount += 1


# ----------------------------------------------------------------------


Ctrl.define
  'eventTest': {}


# ----------------------------------------------------------------------


Ctrl.define
  'render-outer':
    init: ->
      @onInitCount = 0
      @onReadyCount = 0
      @onDestroyedCount = 0

    helpers:
      myFoo: ->
        def =
          type:'foo'
          data: { text:'Hello!' }
          bar:123

          onInit: (ctrl) =>
            @onInitCount += 1
            @onInitArg = ctrl
            @onInitContext = @

          onReady: (ctrl) =>
            @onReadyCount += 1
            @onReadyArg = ctrl
            @onReadyContext = @

          onDestroyed: (ctrl) =>
            @onDestroyedCount += 1
            @onDestroyedArg = ctrl
            @onDestroyedContext = @


# ----------------------------------------------------------------------

Ctrl.define
  'inputTest': {}


Ctrl.define
  'wrappedInputTest':
    api:
      focus: -> @el('input').focus()


