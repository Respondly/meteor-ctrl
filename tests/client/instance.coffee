describe 'Instance', ->
  afterEach -> Test.tearDown()

  it 'has standard structure', (done) ->
    Test.insert 'foo', (instance) =>
      @try =>
        expect(Object.isString(instance.uid)).to.equal true
        expect(instance.type).to.equal 'foo'
        expect(instance.ctrl).to.be.an.instanceOf Ctrl.Ctrl
        expect(Object.isObject(instance.api)).to.equal true
      done()


  it 'invokes callbacks on instance (init/created/destroyed)', (done) ->
    Test.insert 'callbacksTest', (instance) =>
      ctrl = instance.ctrl
      @try =>
          expect(instance.initWasCalled).to.equal true
          expect(instance.createdWasCalled).to.equal true
          instance.dispose()
          expect(instance.destroyedWasCalled).to.equal true
      done()


  it 'invokes [onReady] callbacks (instance)', (done) ->
    instance = Ctrl.defs.foo.insert('body').context
    count = 0
    self = null
    arg = null
    instance.onReady (instance) ->
          self = @
          arg = instance
          count += 1
    Util.delay =>
      @try =>
          expect(count).to.equal 1
          expect(self).to.equal instance
          expect(arg).to.equal instance
      done()


  it 'invokes [onReady] callbacks (ctrl)', (done) ->
    ctrl = Ctrl.defs.foo.insert('body')
    count = 0
    self = null
    arg = null
    ctrl.onReady (c) ->
        count += 1
        self = @
        arg = c
    Util.delay =>
      @try =>
          expect(count).to.equal 1
          expect(self).to.equal ctrl
          expect(arg).to.equal ctrl
      done()


  it 'sets the [isReady] flag', (done) ->
    Test.insert 'foo', (instance) =>
      @try =>
        expect(instance.isReady).to.equal true
      done()


  it 'invokes [onReady] immediately if the Ctrl is already "ready"', (done) ->
    Test.insert 'foo', (instance) =>
      ctrl = instance.ctrl
      @try =>
          expect(ctrl.el()?).to.equal true # Is Ready.
          count = 0
          self = null
          ctrl.onReady ->
              # Immediately invoked.
              self = @
              count += 1
          expect(count).to.equal 1
          expect(self).to.be.an.instanceOf Ctrl.Ctrl
      done()


  it 'invokes the [model] method', (done) ->
    Test.insert 'callbacksTest', (instance) =>
      @try =>
        expect(instance.model().name).to.equal 'my-model'
        expect(instance.modelCount).to.equal 1
      done()





describe 'Instance: dispose', ->
  afterEach -> Test.tearDown()

  it 'results in an "isDisposed" state', (done) ->
    Test.insert 'deep', (instance) =>
      children = instance.children.clone()
      @try =>
          instance.dispose()
          expect(instance.isDisposed).to.equal true
          expect(instance.ctrl.isDisposed).to.equal true

          expect(instance.children.length).to.equal 0
          for child in children
            expect(child.isDisposed).to.equal true
      done()


  it 'removes the ctrl from the DOM', (done) ->
    Test.insert 'foo', (instance) =>
      @try =>
          el = $("div.foo[data-ctrl-uid='#{ instance.uid }']")
          expect(el.length).to.equal 1
          instance.dispose()
          el = $("div.foo[data-ctrl-uid='#{ instance.uid }']")
          expect(el.length).to.equal 0
      done()


  it 'remove the global reference to the instance', (done) ->
    Test.insert 'foo', (instance) =>
      ctrl = instance.ctrl
      @try =>
          expect(Ctrl.ctrls[instance.uid]).to.equal ctrl
          instance.dispose()
          expect(Ctrl.ctrls[instance.uid]).to.be.undefined
      done()


# ----------------------------------------------------------------------


describe 'Instance: API', ->
  afterEach -> Test.tearDown()

  it 'copies API definition', (done) ->
    Test.insert 'apiTest', (instance) =>
      @try =>
        expect(instance.api.myMethod().self).to.equal instance
      done()


  it 'has uses a hash prop', (done) ->
    Test.insert 'apiTest', (instance) =>
      @try =>
          expect(instance.api.myProp()).to.equal 123 # Default value.
          instance.api.myProp('abc')
          expect(instance.api.myProp()).to.equal 'abc'
      done()


# ----------------------------------------------------------------------

describe 'Instance: data', ->
  afterEach -> Test.tearDown()

  it 'has no data', (done) ->
    Test.insert 'foo', (instance) =>
      @try => expect(instance.helpers.data).to.equal undefined
      done()

  it 'copies the "data" value to the instance', (done) ->
    Test.insert 'deep', (instance) =>
      @try =>
          child = instance.children.myChild
          expect(child.context.data).to.eql { foo:123 }
      done()

  it 'makes the "data" value available on [helpers]', (done) ->
    Test.insert 'deep', (instance) =>
      @try =>
          child = instance.children.myChild.context
          expect(child.helpers.data()).to.eql { foo:123 }
      done()



# ----------------------------------------------------------------------


describe 'instance.defaultValue()', ->
  afterEach -> Test.tearDown()

  it 'returns the fallback when default value not available', (done) ->
    Test.insert 'apiTest', (instance) =>
      @try => expect(instance.ctrl.myDefault()).to.equal 'foo'
      done()

  it 'specifies default value from [data]', (done) ->
    Test.insert 'apiTest', data:{ myDefault:123 }, (instance) =>
      @try => expect(instance.ctrl.myDefault()).to.equal 123
      done()

  it 'retrieves default value from function', ->
    Test.insert 'apiTest', data:{ myDefault: -> 'from func' }, (instance) =>
      @try => expect(instance.ctrl.myDefault()).to.equal 'from func'
      done()


  it 'specifies default value from [options] (overriding [data])', (done) ->
    args =
      data: { myDefault:123 }
      myDefault:'abc'
    Test.insert 'apiTest', args, (instance) =>
      @try => expect(instance.ctrl.myDefault()).to.equal 'abc'
      done()


