describe '{{> render}} template', ->
  afterEach -> Test.tearDown()


  it 'renders the control', (done) ->
    Test.insert 'render-outer', (instance) =>
      @try =>
        expect(instance.children.length).to.equal 1
        expect(instance.children[0].type).to.equal 'foo'
      done()


  it 'renders with data', (done) ->
    Test.insert 'render-outer', (instance) =>
      @try =>
        fooCtrl = instance.children[0]
        expect(fooCtrl.context.data).to.eql { text:'Hello!' }
        expect(fooCtrl.text()).to.equal 'Hello!'
      done()


  it 'renders with {option} arguments', (done) ->
    Test.insert 'render-outer', (instance) =>
      @try =>
        fooCtrl = instance.children[0]
        options = fooCtrl.context.options
        expect(options.bar).to.equal 123
      done()


  it 'invokes the [onInit] callback', (done) ->
    Test.insert 'render-outer', (instance) =>
      @try =>
        fooCtrl = instance.children[0]
        expect(instance.onInitCount).to.equal 1
        expect(instance.onInitArg).to.equal fooCtrl
        expect(instance.onInitContext).to.equal instance
      done()


  it 'invokes the [onReady] callback', (done) ->
    Test.insert 'render-outer', (instance) =>
      @try =>
        fooCtrl = instance.children[0]
        expect(instance.onReadyCount).to.equal 1
        expect(instance.onReadyArg).to.equal fooCtrl
        expect(instance.onReadyContext).to.equal instance
      done()




