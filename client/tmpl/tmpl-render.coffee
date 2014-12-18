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

