###
Represents an "context" instance of a control used internally
by the control's code-behind.
###
class Ctrl.CtrlInstance
  constructor: (def, options = {}) ->
    # Setup initial conditions.
    self           = @
    @options       = options
    @id            = options.id if options.id
    @uid           = _.uniqueId('u')
    @type          = def.type
    @api           = {}
    @helpers       = { __instance__:@ } # NB: Temporarily store the instance for retrieval within [created/init] callback.
    @children      = []
    @__internal__  = { def:def }

    # Store parent reference if provided.
    #     This will be passed only when explicitly known at the time
    #     of construction. Otherwise it is derived within the
    #     [tmpl.created] callback.
    if parentCtrl = options.__parentCtrl
      @parent = parentCtrl.context
      delete options.__parentCtrl

    # Store temporary global reference if an "insert" ID was specified.
    # This is retrieved (and cleaned up) via the "insert" method.
    if insertId = options.__insert
      Ctrl.__inserted = @
      delete options.__insert

    wrap = (func) ->
        (args...) -> func.apply(self, args)

    # Wrap API methods.
    @api[key] = wrap(func) for key, func of def.api

    # Wrap helper methods.
    @helpers[key] = wrap(func) for key, func of def.helpers
    @helpers.instance ?= -> "#{ self.type }##{ self.uid }" # Standard output for {{instance}} within a template.
    @helpers.uid ?= @uid
    @helpers.api ?= @api
    @model = wrap(def.model)

    # Store data.
    unless @helpers.data?
      if @options.data
        @data = @options.data
        @helpers.data = => @data

    # Finish up.
    @ctrl = new Ctrl.Ctrl(@)


  ###
  Disposes of the control instance, releasing resources and Deps handles.
  ###
  dispose: ->
    # Setup initial conditions.
    return if @isDisposed
    @isDisposed = true
    internal = @__internal__

    # Remove from the DOM if required.
    # NB: This is only necessary when "dispose" is being called directly
    #     without either Blaze destroying the element, or the "remove" method
    #     having caused the ctrl to be destroyed.
    blazeView = internal.blazeView
    unless blazeView.isDestroyed
      UI.remove(blazeView.domrange)

    # Remove all custom events (jQuery).
    @off() if internal.events?

    # Dispose of children first.
    for child in _.clone(@children)
      child.dispose()

    # Remove from parent.
    if children = @parent?.children
      index = _.indexOf(children, @ctrl)
      children.splice(index, 1) if index > -1
      delete children[@id]

    # Stop [autorun] callbacks.
    if depsHandles = internal.depsHandles
      depsHandles.each (handle) -> handle?.stop?()
      delete internal.depsHandles

    # Invoke [destroyed] method on the instance.
    internal.def.destroyed?.call?(@)

    # Remove global reference.
    delete Ctrl.ctrls[@uid]

    # Dispose of resources.
    internal.onReady?.dispose()
    delete internal.onReady
    internal.session?.dispose()
    internal.hash?.dispose()
    @ctrl.dispose()

    # Invoke callbacks.
    if destroyedHandlers = internal.onDestroyed
      destroyedHandlers.invoke(@ctrl)
      destroyedHandlers.dispose()






  ###
  Safely provides [Deps.autorun] funtionality stopping the
  handle when the control is disposed.
  @param func: The function to monitor.
  ###
  autorun: (func) ->
    handle = Deps.autorun(func)
    depsHandles = @__internal__.depsHandles ?= []
    depsHandles.push(handle)
    handle



  ###
  Retrieves the a jQuery element for the control.
  @param selector:  Optional. A CSS selector to search within the element's DOM for.
                    If ommited the root element is returned.
  ###
  find: (selector) ->
    if el = @__internal__.blazeView?.domrange?.members[0]
      if not selector? or selector is ''
        $(el)
      else
        $(el).find(selector)


  # Alias to "find".
  el: (selector) -> @find(selector)


  ###
  Appends a child control.
  @param def: The Ctrl definition
                - Object: The definition object.
                - String: The type of the Ctrl.

  @param el:  The element to insert within. Can be:
                - jQuery element
                - String (CSS selector)
                - null (uses root element of the control)

  @param beforeEl:  (optional) The element to insert before.

  @param args: The control arguments.
  ###
  appendCtrl: (def, el, beforeEl, args) ->

    # Setup initial conditions.
    if beforeEl?
      if not args? and not (beforeEl.jquery or beforeEl.nodeType is 1)
        args = beforeEl
        beforeEl = null

    # Look up the Ctrl definition if required.
    if Object.isString(def)
      typeName = def
      def = Ctrl.defs[typeName]

    unless def?
      msg = '[appendCtrl] definition required.'
      msg += " Type not found: '#{ typeName }'" if typeName
      throw new Error(msg)

    # Insert the control.
    el = @find(el) unless el?.jquery?
    ctrl = def.insert(el, beforeEl, args, @ctrl)

    # Establish the parent/child relationships.
    INTERNAL.registerChild(@, ctrl.context)

    # Finish up.
    ctrl




  ###
  Registers a handler to be run when the ctrl is DOM "ready".
  @param func: The function to invoke.
  ###
  onReady: (func) ->
    if @isReady
      # Invoke immediately if already "ready".
      func(@ctrl) if Object.isFunction(func)

    else
      handlers = @__internal__.onReady ?= new Handlers()
      handlers.push(func)



  ###
  Registers a handler to be run when the control is disposed of.
  @param func: The function to invoke.
  ###
  onDestroyed: (func) ->
    if @isDisposed
      # Invoke immediately if already "ready".
      func(@ctrl) if Object.isFunction(func)

    else
      handlers = @__internal__.onDestroyed ?= new Handlers()
      handlers.push(func)




  ###
  Retrieves the a scoped-session for the ctrl.
  ###
  session: -> session = @__internal__.session ?= new ScopedSession("ctrl:#{ @uid }")



  ###
  Retrieves the a reactive-hash for the ctrl.
  ###
  hash: -> session = @__internal__.hash ?= new ReactiveHash()



  ###
  Gets or sets the property value for the given key.
  @param key:         The unique identifier of the value (this is prefixed with the namespace).
  @param value:       (optional). The value to set (pass null to remove).
  @param options:
            default:  (optional). The default value to return if the session does not contain the value (ie. undefined).
            onlyOnChange:  (optional). Will only call set if the value has changed.
                                       Default:true
  ###
  prop: (key, value, options = {}) ->
    options.onlyOnChange ?= true
    options.default = @defaultValue(key, options.default)
    @hash().prop(key, value, options)



  ###
  Walks up the hierarchy returning the first ancestor that
  matches the given selector.
  @param selector:
            - type: The name of the type to look for.
  @returns The matching ancestor [Instance] or Null.
  ###
  ancestor: (selector = {}) ->
    walk = (instance) ->
              return null unless instance?
              if type = selector.type
                if matchType(type, instance)
                  return instance
                else
                  return walk(instance.parent) # <== RECURSION.
              # Not found.
              null
    walk(@parent)



  ###
  Finds the closest matching control Instance.
  @param selector: See 'ancestor'
  @returns
        - This instance (if matched),
        - The matching ancestor
        - Null.
  ###
  closest: (selector = {}) ->
    if type = selector.type
      return @ if matchType(type, @)
    @ancestor(selector)


  ###
  Looks on the [data] then the [options] for the given value,
  and if it's a function executes it to convert it to a value.

  @param attr:          The key of the attribute to read.
  @param defaultValue:  Optional. The default value to use if not found.

  ###
  defaultValue: (attr, defaultValue) ->
    values = [ @options?[attr], @data?[attr] ]
    for value in values
      if value isnt undefined
        value = Util.asValue(value, defaultValue)
        return value if value isnt undefined

    # No-value.
    defaultValue


  ###
  Registers a custom event for the control.
  @param event:           The name of the event (eg. 'my:event')
  @param func(j, args):   The event handlers/
                          - j:      The jQuery event args.
                          - args:   The arguments object passed with the
                                    custom event.
  ###
  on: (event, func) -> events(@).on(event, func)


  ###
  Remove a custom event handler from the control.
  @param event:  The name of the event (eg. 'my:event')
  @param func:   The event handler function.
  ###
  off: (event, func) -> events(@).off(event, func)


  ###
  Triggers a custom event.
  @param event:  The name of the event (eg. 'my:event')
  @param args:   Optional. Arguments to pass with the event.
  ###
  trigger: (event, args) -> events(@).trigger(event, args)



  ###
  Allows property style read/write operations on CSS values.
  Example:

    maxWidth: (value) -> @css 'max-width', value, unit:'px'

    isVisible: (value) ->
      @css 'display', value,
        onRead: (value) -> value is 'block'
        onWrite: (value) -> if value then 'block' else 'none'


  @param style:     The CSS style under consideration.
  @param value:     Optional.  The CSS value to write.
                    Ommit for read operations.
                    Pass null or empty-string ('') to remove the CSS property.
  @param options:
            - unit:            Optional.  The value's unit, eg 'px'.
            - selector:        Optional.  The CSS selector.  The root element of the control is used if ommitted.
            - onRead(value):   Optional.  A function that transforms the value upon reading.
            - onWrite(value):  Optional.  A function that transforms the value upon reading.

  @returns The CSS value, or null if the value does not exist.
  ###
  css: (style, value, options = {}) ->
    # Setup initial conditions.
    return unless @find
    el   = @find(options.selector)
    unit = options.unit

    onRead  = options.onRead
    onWrite = options.onWrite

    # Write.
    if value isnt undefined
      value = onWrite(value) if Object.isFunction(onWrite)
      write = value ? ''
      write += unit if value and unit
      el.css(style, write)

    # Read.
    result = el?.css(style)
    result = null if Util.isBlank(result)
    result = result ? null
    result = onRead(result) if Object.isFunction(onRead)

    # Finish up.
    result



# PRIVATE ----------------------------------------------------------------------



matchType = (type, obj) -> obj?.type is type




events = (instance) ->
  internal = instance.__internal__
  internal.events = new Util.Events() unless internal.events
  internal.events





INTERNAL.registerChild = (parentInstance, childInstance) ->
  return unless (parentInstance? and childInstance?)

  # Update parent reference.
  childInstance.parent = parentInstance
  childInstance.ctrl.parent = parentInstance.ctrl

  push = (item, children) ->
      alreadyExists = children.any (value) -> value.uid is item.uid
      children.push(item) unless alreadyExists

  # Update [children] collection.
  push(childInstance.ctrl, parentInstance.children)
  if id = childInstance.options.id
    parentInstance.children[id] = childInstance.ctrl


