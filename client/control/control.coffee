###
Represents the public API of a control.
###
class Ctrl.Ctrl
  ###
  Constructor.
  @param context: The Ctrl instance.
  ###
  constructor: (@context) ->
    instance  = @context
    @type     = instance.type
    @uid      = instance.uid
    @id       = instance.id if instance.id # NB: ID only exists if specified within the tmplate {{ id=123 }}

    # Copy API.
    for key, func of instance.api
      do (key, func) =>
        @[key] = (args...) -> instance.api[key].apply(instance, args)





  ###
  Disposes of the control.
  ###
  dispose: ->
    return if @isDisposed
    @isDisposed = true
    @context.dispose()


  ###
  Retrieves the a jQuery element for the control.
  @param selector:  Optional. A CSS selector to search within the element's DOM for.
                    If ommited the root element is returned.
  ###
  el: (selector) -> @context.find(selector)



  ###
  Registers a handler to be run when the ctrl is DOM "ready".
  @param func(ctrl): The function to invoke.
  ###
  onReady: (func) -> @context.onReady(func)


  ###
  Registers a handler to be run when the control is disposed of.
  @param func: The function to invoke.
  ###
  onDestroyed: (func) -> @context.onDestroyed(func)



  ###
  Registers a custom event for the control.
  @param event:           The name of the event (eg. 'my:event')
  @param func(j, args):   The event handlers/
                          - j:      The jQuery event args.
                          - args:   The arguments object passed with the
                                    custom event.
  ###
  on: (event, func) -> @context.on(event, func)


  ###
  Remove a custom event handler from the control.
  @param event:  The name of the event (eg. 'my:event')
  @param func:   The event handler function.
  ###
  off: (event, func) -> @context.off(event, func)



  ###
  Walks up the hierarchy returning the first ancestor that
  matches the given selector.
  @param selector:
            - type: The name of the type to look for.
  @returns The matching ancestor [Instance] or Null.
  ###
  ancestor: (selector) -> @context.ancestor(selector)?.ctrl ? null


  ###
  Finds the closest matching control Instance.
  @param selector: See 'ancestor'
  @returns
        - This instance (if matched),
        - The matching ancestor
        - Null.
  ###
  closest: (selector) -> @context.closest(selector)?.ctrl ? null


  ###
  Places focus on the control.

    NOTE: Override this method to place focus on a specific
          child element within the control

  ###
  focus: -> @el().focus()


  ###
  Removes focus from the element.
  ###
  blur: ->
    if @hasFocus()
      $(document.activeElement).blur()


  ###
  Determines whether the control has focus.
  ###
  hasFocus: -> @context.hasFocus()


