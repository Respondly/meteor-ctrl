describe '[onReady] callback', ->
  afterEach -> Test.tearDown()


  it 'invokes [onReady] callbacks (instance)', (done) ->
    instance = Ctrl.defs.foo.insert('body').context
    count = 0
    arg = null
    instance.onReady (ctrl) ->
          arg = ctrl
          count += 1
    Util.delay =>
      @try =>
          expect(count).to.equal 1
          expect(arg).to.equal instance.ctrl
      done()


  it 'invokes [onReady] callbacks (ctrl)', (done) ->
    ctrl = Ctrl.defs.foo.insert('body')
    count = 0
    arg = null
    ctrl.onReady (c) ->
        count += 1
        arg = c
    Util.delay =>
      @try =>
          expect(count).to.equal 1
          expect(arg).to.equal ctrl
      done()


  it 'invokes [onReady] immediately if the Ctrl is already "ready"', (done) ->
    Test.insert 'foo', (instance) =>
      ctrl = instance.ctrl
      @try =>
          expect(ctrl.el()?).to.equal true # Is Ready.
          count = 0
          arg = null
          ctrl.onReady (c) ->
              # Immediately invoked.
              count += 1
              arg = c
          expect(count).to.equal 1
          expect(arg).to.equal ctrl
      done()



# ----------------------------------------------------------------------



describe '[onDestroyed] callback', ->
  afterEach -> Test.tearDown()

  it 'invokes [onDestroyed] callbacks (instance)', (done) ->
    count = 0
    arg = null

    Test.insert 'foo', (instance) =>
      instance.onDestroyed (c) ->
        count += 1
        arg = c

      @try =>
        instance.dispose()
        instance.dispose()
        expect(count).to.equal 1
        expect(arg).to.equal instance.ctrl
      done()


  it 'invokes [onDestroyed] callbacks (ctrl)', (done) ->
    count = 0
    arg = null

    Test.insert 'foo', (instance) =>
      instance.ctrl.onDestroyed (c) ->
        count += 1
        arg = c

      @try =>
        instance.dispose()
        instance.dispose()
        expect(count).to.equal 1
        expect(arg).to.equal instance.ctrl
        expect(arg.isDisposed).to.equal true
      done()


  it 'invokes [onDestroyed] immediately if the Ctrl is already disposed of', (done) ->
    count = 0
    arg = null

    Test.insert 'foo', (instance) =>
      instance.dispose()
      expect(instance.isDisposed).to.equal true

      instance.ctrl.onDestroyed (c) ->
        count += 1
        arg = c

      @try =>
        expect(count).to.equal 1
        expect(arg).to.equal instance.ctrl
      done()








