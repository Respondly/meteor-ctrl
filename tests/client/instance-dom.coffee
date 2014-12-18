describe 'instance.ancestor()', ->
  afterEach -> Test.tearDown()

  it 'does not find an ancestor', (done) ->
    Test.insert 'deep', (instance) =>
          deepChild = instance.children.myChild.context.children.foo
          expect(deepChild.ancestor()).to.equal null
          expect(deepChild.ancestor(type:null)).to.equal null
          expect(deepChild.ancestor(type:'')).to.equal null
          expect(deepChild.ancestor(type:'not-exist')).to.equal null
          expect(deepChild.context.ancestor(type:'not-exist')).to.equal null
          done()


  it 'finds the first ancestor', (done) ->
    Test.insert 'deep', (instance) =>
          deepChild = instance.children.myChild.context.children.foo
          expect(deepChild.ancestor(type:'deep')).to.equal instance.ctrl
          expect(deepChild.context.ancestor(type:'deep')).to.equal instance
          done()


  it 'defaults a string parmeter to { type:string }', (done) ->
    Test.insert 'deep', (instance) =>
          deepChild = instance.children.myChild.context.children.foo
          expect(deepChild.ancestor('deep')).to.equal instance.ctrl
          expect(deepChild.context.ancestor('deep')).to.equal instance
          done()


  it 'finds the first using a partial type-name', (done) ->
    Test.insert 'deep', (instance) =>
          deepChild = instance.children.myChild.context.children.foo
          ancestor = deepChild.ancestor(type:'-child')
          expect(ancestor).to.equal instance.children.myChild
          done()


  it 'does not find the same type ancestor', (done) ->
    Test.insert 'deep', (instance) =>
          deepChild = instance.children.myChild.context.children.foo
          expect(deepChild.ancestor(type:'foo')).to.equal null
          expect(deepChild.context.ancestor(type:'foo')).to.equal null
          done()




# ----------------------------------------------------------------------


describe 'instance.closest()', ->
  afterEach -> Test.tearDown()

  it 'does not find the closesst ancestor', (done) ->
    Test.insert 'deep', (instance) =>
          deepChild = instance.children.myChild.context.children.foo
          expect(deepChild.closest(type:'not-found')).to.equal null
          expect(deepChild.context.closest(type:'not-found')).to.equal null
          done()

  it 'finds the closesst ancestor', (done) ->
    Test.insert 'deep', (instance) =>
          deepChild = instance.children.myChild.context.children.foo
          expect(deepChild.closest(type:'deep')).to.equal instance.ctrl
          expect(deepChild.context.closest(type:'deep')).to.equal instance
          done()

  it 'finds the same instance', (done) ->
    Test.insert 'deep', (instance) =>
          deepChild = instance.children.myChild.context.children.foo
          expect(deepChild.closest(type:'foo')).to.equal deepChild
          expect(deepChild.context.closest(type:'foo')).to.equal deepChild.context
          done()



# ----------------------------------------------------------------------



describe 'Instance: [find] and [el] methods', ->
  afterEach -> Test.tearDown()

  it 'has both [find] and [el] methods', (done) ->
    Test.insert 'foo', (instance) =>
          expect(instance.find().attr("data-ctrl")).to.equal "foo##{ instance.uid }"
          expect(instance.el().attr("data-ctrl")).to.equal "foo##{ instance.uid }"
          done()

  it 'finds child elements with CSS selector', (done) ->
    Test.insert 'foo', { text:'Hello' }, (instance) =>
          el = instance.find('code')
          expect(el.html()).to.equal "Hello:#{ instance.uid }"

          el = instance.el('code')
          expect(el.html()).to.equal "Hello:#{ instance.uid }"

          done()



# ----------------------------------------------------------------------



describe 'instance.css', ->
  instance = null
  ctrl = null
  el = null
  afterEach -> Test.tearDown()
  beforeEach (done) ->
    Test.insert 'foo', (i) =>
          instance = i
          ctrl = instance.ctrl
          el = ctrl.el()
          done()


  it 'writes a style', ->
    instance.css 'opacity', 0.5
    expect(el.css('opacity')).to.equal '0.5'

  it 'writes a style with units', ->
    instance.css 'min-width', 10, unit:'px'
    expect(el.css('min-width')).to.equal '10px'

  it 'reads a value as string', ->
    instance.css 'min-width', 10, unit:'px'
    expect(instance.css('min-width')).to.equal '10px'

  it 'sets a value to default', ->
    instance.css 'display', ''
    expect(instance.css('display')).to.equal 'block'

    instance.css 'display', null
    expect(instance.css('display')).to.equal 'block'


  it 'transforms on read', ->
    onRead = (value) -> value.toNumber()
    prop = (value) -> instance.css 'min-width', value, unit:'px', onRead: onRead
    prop(10)
    expect(prop()).to.equal 10

  it 'transforms on write', ->
    prop1 = (value) -> instance.css 'display', value # , onWrite:onWrite
    prop1('inline-block')
    expect(prop1()).to.equal 'inline-block'

    onWrite = (value) -> 'none'
    prop2 = (value) -> instance.css 'display', value, onWrite:onWrite
    prop2('inline-block')
    expect(prop2()).to.equal 'none'


