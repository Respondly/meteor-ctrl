###
The container template for a [Ctrl].

    This dynamically renders the declared 'type' passing it a
    Ctrl [Instance] as the context.

    The type corresponds with the <template> name.

Eample usage:


    {{> ctrl type="my-type" data=data id='myThing' foo=123 }}


###
Template.ctrl.helpers
  ###
  The template name: {{> UI.dynamic template=name data=context }}
  ###
  name: -> @type


  ###
  The templates data context: {{> UI.dynamic template=name data=context }}
  ###
  context: ->
    options = @

    # Retrieve the template name, and clear it off the options object.
    tmpl = options.type
    delete options.type

    # Retrieve the control definition.
    ctrl = Ctrl.defs[tmpl]
    if not ctrl
      throw new Error("The control of type '#{ tmpl }' has not been defined.")

    # Return the instance helpers as the data context for the rendered template.
    return new Ctrl.CtrlInstance(ctrl.def, options).helpers




# ----------------------------------------------------------------------



###
Provides a way for a [Ctrl] to be easily rendered as the result
of a helper function.

  For example:

        {{> render ctrl=myFoo }}

  Where "myFoo" is the result of a helper method:

      helpers:
        myFoo: ->
          def =
            type: 'foo'
            data: { text:'Hello from Data' }
            onInit: (ctrl) =>
            onReady: (ctrl) =>
            bar: 123 # Any argument for the [options].


###
Template.render.helpers
  ctrlRef: ->
    if ctrl = @ctrl

      # Use the {options} object if specified.
      if Object.isObject(ctrl.options)
        options = @ctrl.options
      else
        options = {}

      # Copy values from the definition on the {options}.
      for key, value of ctrl
        unless key is 'type' or key is 'data'
          options[key] ?= value

      result =
        type: ctrl.type
        data: ctrl.data
        options: options



