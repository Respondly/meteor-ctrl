describe 'Instance', ->
  afterEach -> Test.tearDown()

  it 'has standard structure', (done) ->
    Test.insert 'foo', (instance) =>
          expect(Object.isString(instance.uid)).to.equal true
          expect(instance.type).to.equal 'foo'
          expect(instance.ctrl).to.be.an.instanceOf Ctrl.Ctrl
          expect(instance.data).to.eql {}
          expect(instance.options).to.eql {}
          expect(instance.children).to.eql []
          expect(instance.isReady).to.equal true
          expect(instance.api).to.be.an.instanceOf Object
          expect(instance.helpers).to.be.an.instanceOf Object
          expect(instance.model).to.be.an.instanceOf Function
          done()


  it 'invokes callbacks on instance (init/created/destroyed)', (done) ->
    Test.insert 'callbacksTest', (instance) =>
      ctrl = instance.ctrl
      expect(instance.initWasCalled).to.equal true
      expect(instance.createdWasCalled).to.equal true
      instance.dispose()
      expect(instance.destroyedWasCalled).to.equal true
      done()


  it 'sets the [isReady] flag', (done) ->
    Test.insert 'foo', (instance) =>
        expect(instance.isReady).to.equal true
        done()


  it 'invokes the [model] method', (done) ->
    Test.insert 'callbacksTest', (instance) =>
        expect(instance.model().name).to.equal 'my-model'
        expect(instance.modelCount).to.equal 1
        done()



# ----------------------------------------------------------------------



describe 'Instance: dispose', ->
  afterEach -> Test.tearDown()

  it 'results in an "isDisposed" state', (done) ->
    Test.insert 'deep', (instance) =>
        children = instance.children.clone()
        instance.dispose()
        expect(instance.isDisposed).to.equal true
        expect(instance.ctrl.isDisposed).to.equal true

        expect(instance.children.length).to.equal 0
        for child in children
          expect(child.isDisposed).to.equal true
        done()


  it 'removes the ctrl from the DOM', (done) ->
    Test.insert 'foo', (instance) =>
          el = $("div.foo[data-ctrl='foo##{ instance.uid }']")
          expect(el.length).to.equal 1
          instance.dispose()
          el = $("div.foo[data-ctrl='foo##{ instance.uid }']")
          expect(el.length).to.equal 0
          done()


  it 'remove the global reference to the instance', (done) ->
    Test.insert 'foo', (instance) =>
          ctrl = instance.ctrl
          expect(Ctrl.ctrls[instance.uid]).to.equal ctrl
          instance.dispose()
          expect(Ctrl.ctrls[instance.uid]).to.be.undefined
          done()


# ----------------------------------------------------------------------


describe 'Instance: API', ->
  afterEach -> Test.tearDown()

  it 'copies API definition', (done) ->
    Test.insert 'apiTest', (instance) =>
        expect(instance.api.myMethod().self).to.equal instance
        done()


  it 'has uses a hash prop', (done) ->
    Test.insert 'apiTest', (instance) =>
          expect(instance.api.myProp()).to.equal 123 # Default value.
          instance.api.myProp('abc')
          expect(instance.api.myProp()).to.equal 'abc'
          done()


# ----------------------------------------------------------------------


describe 'Instance: data', ->
  afterEach -> Test.tearDown()

  it 'has an empty data object', (done) ->
    Test.insert 'foo', (instance) =>
        expect(instance.data).to.eql {}
        done()

  it 'has the same empty data object on helpers', (done) ->
    Test.insert 'foo', (instance) =>
        expect(instance.helpers.data).to.equal instance.data
        done()

  it 'stores the "data" options argument', (done) ->
    myData = {foo:123}
    Test.insert 'foo', data:myData, (instance) =>
        expect(instance.data).to.equal myData
        expect(instance.helpers.data).to.equal myData
        done()

  it 'copies the "data" value to the instance', (done) ->
    Test.insert 'deep', (instance) =>
        child = instance.children.myChild
        expect(child.context.data).to.eql { foo:123 }
        done()

  it 'makes the "data" value available on [helpers]', (done) ->
    Test.insert 'deep', (instance) =>
        child = instance.children.myChild.context
        expect(child.helpers.data).to.eql { foo:123 }
        done()


# ----------------------------------------------------------------------


describe 'Instance: options', ->
  afterEach -> Test.tearDown()

  it 'has empty {} options', (done) ->
    Test.insert 'foo', (instance) =>
      expect(instance.options).to.eql {}
      done()

  it 'has simple {foo:123} options', (done) ->
    Test.insert 'foo', {foo:123}, (instance) =>
        expect(instance.options.foo).to.equal 123
        done()

  it 'has data as options', (done) ->
    data = { bar:'abc' }
    Test.insert 'foo', { foo:123, data:data }, (instance) =>
        expect(instance.options.foo).to.equal 123
        expect(instance.options.data).to.equal data
        expect(instance.data).to.equal data
        done()

  it 'flattens sub-options onto the base {options} object', (done) ->
    options =
      foo:123
      options:
        bar:456
        fn: -> 'hello'

    Test.insert 'foo', options, (instance) =>
        expect(instance.options.foo).to.equal 123
        expect(instance.options.bar).to.equal 456
        expect(instance.options.fn()).to.equal 'hello'
        expect(instance.options.options).to.equal undefined
        done()



# ----------------------------------------------------------------------



describe 'instance.defaultValue()', ->
  afterEach -> Test.tearDown()

  it 'returns the fallback when default value not available', (done) ->
    Test.insert 'apiTest', (instance) =>
      expect(instance.ctrl.myDefault()).to.equal 'foo'
      done()

  it 'specifies default value from [data]', (done) ->
    Test.insert 'apiTest', data:{ myDefault:123 }, (instance) =>
      expect(instance.ctrl.myDefault()).to.equal 123
      done()

  it 'retrieves default value from function', ->
    Test.insert 'apiTest', data:{ myDefault: -> 'from func' }, (instance) =>
      expect(instance.ctrl.myDefault()).to.equal 'from func'
      done()


  it 'specifies default value from [options] (overriding [data])', (done) ->
    args =
      data: { myDefault:123 }
      myDefault:'abc'
    Test.insert 'apiTest', args, (instance) =>
      expect(instance.ctrl.myDefault()).to.equal 'abc'
      done()


