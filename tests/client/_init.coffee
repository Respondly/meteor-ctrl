#= base
@Test = {}
@expect = chai.expect


if Meteor.isClient
  Meteor.startup -> $('title').html('Tests: Ctrl')


# --------------------------------------------------------------------------


Test.insert = (ctrlDef, options, callback) ->
  if Object.isFunction(options)
    callback = options
    options = undefined

  ctrlDef = Ctrl.defs[ctrlDef] if Object.isString(ctrlDef)
  ctrl = ctrlDef.insert('body', options)
  ctrl.onReady (c) ->
    Util.delay ->
      callback?(c.context)



Test.tearDown = ->
  # Remove all ctrl instances.
  for key, ctrl of Ctrl.ctrls
    ctrl.dispose()


