describe 'Instance: autorun', ->
  afterEach -> Test.tearDown()

  it 're-runs the autorun function', (done) ->
    KEY = 'reactive-value'
    Test.insert 'autorun', (instance) =>
      Util.delay 10, =>
        Session.set(KEY, 'a')
        Util.delay 10, =>
          Session.set(KEY, 'b')
          @try =>
              expect(instance.runCount).to.equal 2
          done()


# ----------------------------------------------------------------------



describe 'Instance: ReactiveHash', ->
  afterEach -> Test.tearDown()

  it 'has a ReactiveHash', (done) ->
    Test.insert 'foo', (instance) =>
      @try =>
          expect(instance.hash()).to.be.an.instanceof ReactiveHash
          expect(instance.hash()).to.equal instance.hash() # Same instance.
      done()

  it 'disposes of the ReactiveHash', (done) ->
    Test.insert 'foo', (instance) =>
      @try =>
          hash = instance.hash()
          instance.dispose()
          expect(hash.isDisposed).to.equal true
      done()



describe 'Instance: Prop', ->
  afterEach -> Test.tearDown()

  it 'reads a value from the hash', (done) ->
    Test.insert 'foo', (instance) =>
      instance.hash().set('myProp', 123)
      @try => expect(instance.prop('myProp')).to.equal 123
      done()

  it 'writes a value to the hash', (done) ->
    Test.insert 'foo', (instance) =>
      instance.prop('myProp', 123)
      @try =>
          hash = instance.hash()
          expect(hash.get('myProp')).to.equal 123
          expect(hash.keys.myProp).to.equal 123
      done()


  it '[onlyOnChange] flag is true (default)', (done) ->
    Test.insert 'foo', (instance) =>
      count = 0
      Deps.autorun ->
          instance.prop('myProp') # Hook into reactive callback.
          count += 1

      count = 0
      instance.prop('myProp', 123) # Change 1.
      Util.delay =>
        instance.prop('myProp', 123) # Change 2 (no change).
        Util.delay =>
          @try => expect(count).to.equal 1
          done()


  it '[onlyOnChange] flag is false', ->
    Test.insert 'foo', (instance) =>
      count = 0
      Deps.autorun ->
          instance.prop('myProp') # Hook into reactive callback.
          count += 1

      count = 0
      instance.prop('myProp', 123, onlyOnChange:false) # Change 1.
      Util.delay =>
        instance.prop('myProp', 123, onlyOnChange:false) # Change 2 (no change).
        Util.delay =>
          @try => expect(count).to.equal 2
          done()


  it 'looks for [default] value by default', (done) ->
    Test.insert 'foo', {myProp:'hello'}, (instance) =>
      @try =>
        value = instance.prop('myProp')
        expect(instance.prop('myProp')).to.equal 'hello'
      done()


  it 'takes explicit [default] value by default', ->
    Test.insert 'foo', (instance) =>
      value = instance.prop('myProp', undefined, default:'my-default')
      @try -> expect(value).to.equal 'my-default'

      value = instance.prop('myProp', undefined, default:false)
      @try -> expect(value).to.equal false

      value = instance.prop('myProp', undefined, default:null)
      @try -> expect(value).to.equal null

      done()


  it 'works with when using [@defaultValue] ', (done) ->
    # NB: This is for legacy code that is declared with [@defaultValue]
    #     within the property declaration.
    Test.insert 'foo', {myProp:'hello'}, (instance) =>
      @try =>
        value = instance.prop('myProp', undefined, default:instance.defaultValue('myProp', 'foo'))
        expect(instance.prop('myProp')).to.equal 'hello'
      done()



# ----------------------------------------------------------------------




describe 'Instance: ScopedSession', ->
  afterEach -> Test.tearDown()

  it 'has a session with a namespace of the UID', (done) ->
    Test.insert 'foo', (instance) =>
      @try => expect(instance.session().namespace).to.equal "__ctrl:#{ instance.uid }"
      done()

  it 'has returns the same instance of the session', (done) ->
    Test.insert 'foo', (instance) =>
      @try =>
        session1 = instance.session()
        session2 = instance.session()
        expect(session1).to.equal session2
      done()

  it 'disposes of the session', (done) ->
    Test.insert 'foo', (instance) =>
      @try =>
        session = instance.session()
        instance.dispose()
        expect(session.isDisposed).to.equal true
      done()
