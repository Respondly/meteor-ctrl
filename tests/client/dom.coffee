findElement = (ctrl) -> $("div.foo[data-ctrl='#{ ctrl.type }##{ ctrl.uid }']")


describe 'DOM: insert', ->
  afterEach -> Test.tearDown()

  it 'inserts into the DOM with the "data-ctrl-uid" attribute', (done) ->
    Ctrl.defs.foo.insert('body').onReady (ctrl) =>
        # Ensure the element exist within the DOM.
        el = findElement(ctrl)
        expect(el[0]).to.exist
        done()


describe 'Ctrl.fromElement', ->
  afterEach -> Test.tearDown()

  it 'via jQuery element', (done) ->
    Test.insert 'foo', (instance) =>
        el = findElement(instance)
        expect(Ctrl.fromElement(el)).to.equal instance.ctrl
        done()


  it 'via DOM element', (done) ->
    Test.insert 'foo', (instance) =>
        el = findElement(instance)
        expect(Ctrl.fromElement(el[0])).to.equal instance.ctrl
        done()


  it 'via CSS selector', (done) ->
    Test.insert 'foo', (instance) =>
        expect(Ctrl.fromElement("div.foo[data-ctrl='foo##{ instance.uid }']")).to.equal instance.ctrl
        done()


  it 'via Event object', (done) ->
    Test.insert 'foo', (instance) =>
        e = new jQuery.Event('click')
        e.target = instance.el()[0]
        expect(Ctrl.fromElement(e)).to.equal instance.ctrl
        done()


  it 'returns nothing when not found', (done) ->
    Test.insert 'foo', (instance) =>
        expect(Ctrl.fromElement($(".not-exist"))).to.equal undefined
        expect(Ctrl.fromElement(".not-exist")).to.equal undefined
        expect(Ctrl.fromElement("")).to.equal undefined
        expect(Ctrl.fromElement(null)).to.equal undefined
        expect(Ctrl.fromElement()).to.equal undefined
        done()
