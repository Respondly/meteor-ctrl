###
The container template for a [Ctrl].

    This dynamically renders the declared 'type' passing it a
    Ctrl [Instance] as the context.

    The type corresponds with the <template> name.

Eample usage:


    {{> ctrl type="my-type" data=data id='myThing' foo=123 }}


###
Template.ctrl.helpers
  context: ->
    options = @

    # Retrieve the template name, and clear it off the options object.
    type = options.type
    delete options.type
    if not type
      throw new Error("A control type has not been specified, eg: {{> ctrl type='foo' }}.")

    # Retrieve the control definition.
    ctrl = Ctrl.defs[type]
    if not ctrl
      throw new Error("The control of type '#{ type }' has not been defined.")

    # Create the new logical instance
    instance = new Ctrl.CtrlInstance(ctrl.def, options)

    # Finish up.
    result =
      tmpl: ctrl.tmpl
      data: instance.helpers  # NB: The helpers are used as the data
                              #     context for the Blaze template.
