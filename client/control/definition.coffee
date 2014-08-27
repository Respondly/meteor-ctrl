###
The definition of a control.
###
class Ctrl.CtrlDefinition
  ###
  Constructor.
  @param type: The type/template name.
  @param def:  An object containing the callbacks used within the control instance.
  ###
  constructor: (@type, @def = {}) ->
    # Setup initial conditions.
    self = @
    def = @def
    @def.type ?= @type
    @tmpl = tmpl = Template[@type]
    throw new Error("Template '#{ @type }' does not exist.") unless @tmpl

    # Ensure objects exist.
    def.api     ?= {}
    def.helpers ?= {}
    def.events  ?= {}

    invoke = (context, funcName, args) =>
            instance = context.__instance__
            unless instance.isDisposed
              args = [args] unless _.isArray(args)
              @def[funcName]?.apply?(instance, args)


    # INIT (invoked at construction, prior to the DOM being available).
    tmpl.created = ->
        unless @data
          throw new Error("Use {{> ctrl type='#{ def.type }' }} to insert the ctrl within a template.")

        # Retrieve the ctrl instance from the data (helpers) object,
        # then clean up the data object.
        instance = @__instance__ = @data.__instance__
        delete @data.__instance__

        # Cross reference blaze-view/instance.
        blazeView = @__view__
        blazeView.__instance__ = instance
        instance.__internal__.blazeView = blazeView

        # Store global reference to the instance.
        Ctrl.ctrls[instance.uid] = instance.ctrl

        # Retrieve a reference to the parent control.
        findParent = (blazeView) ->
                return unless blazeView
                if inst = blazeView.__instance__
                  return inst
                else
                  findParent(blazeView.parentView) # <== RECURSION.

        parent = instance.parent ? findParent(blazeView.parentView)
        INTERNAL.registerChild(parent, instance)

        # Invoke the "init" method on the instance.
        invoke(@, 'init')


    # CREATED (DOM Ready).
    tmpl.rendered = ->
        instance = @__instance__
        instance.isReady = true

        # Ensure that the control has a single root element.
        if @__view__.domrange.members.length > 1
          throw new Error("The [#{ self.type }] ctrl has more than one top-level element in the template.")

        # Add the UID attribute.
        instance.find().attr('data-ctrl-uid', instance.uid)

        # Invoke the "created" method on the instance.
        invoke(@, 'ready')

        # Invoke any "ready" handlers.
        if handlers = instance.__internal__.onReady
          handlers.invoke(instance)
          handlers.dispose()
          delete instance.__internal__.onReady

    # DESTROYED.
    tmpl.destroyed = -> @__instance__.dispose()

    # Prepare events.
    wrapEvent = (func) -> (e, context) -> func.call(context.__instance__, e)
    def.events[key] = wrapEvent(func) for key, func of def.events
    tmpl.events(def.events)





  ###
  Inserts a new instance of the control into the DOM.
  @param parentElement: The element to insert into. Can be:
                          - DOM element
                          - jQuery element
                          - String (CSS selector)
  @param beforeEl:    (optional) The element to insert before.
  @param args:        The named data arguments to supply to the control.
  @param parentCtrl:  (optional) A reference to the parent control.
  ###
  insert: (parentEl, beforeEl, args, parentCtrl) ->
    # Setup initial conditions.
    if beforeEl?
      if not args? and not (beforeEl.jquery or beforeEl.nodeType is 1)
        args = beforeEl
        beforeEl = null

    # Prepare the args that are passed to the control.
    args ?= {}
    args.type = @type
    args.__insert = _.uniqueId() # Temporarily store an ID to retrieve the instance with.
    args.__parentCtrl = parentCtrl if parentCtrl?

    processEl = (el) ->
        if el
          el = $(el) if _.isString(el)
          el = el[0] if el.jquery
          el

    # Process the element to insert into.
    parentEl = processEl(parentEl)
    beforeEl = processEl(beforeEl)

    # Render the control.
    domrange = UI.renderWithData(Template.ctrl, args)
    UI.insert(domrange, parentEl, beforeEl)

    # Retrieve the new instance.
    instance = Ctrl.__inserted
    delete Ctrl.__inserted
    instance

    # Finish up.
    instance.ctrl
