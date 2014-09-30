describe 'Instance: parent/children', ->
  afterEach -> Test.tearDown()

  it 'has children', (done) ->
    Test.insert 'deep', (instance) =>
      @try =>
          children = instance.children
          expect(instance.parent).to.be.undefined

          # Children array.
          expect(children.length).to.equal 3
          expect(children[0]).to.be.an.instanceOf Ctrl.Ctrl
          expect(children[0].type).to.equal 'foo'
          expect(children[1].type).to.equal 'deep-child'
          expect(children[2].type).to.equal 'foo'

          # Children by "id".
          expect(children.myChild).to.equal children[1]
          expect(children.myFoo).to.equal instance.children[2]

      done()


  it 'has parent', (done) ->
    Test.insert 'deep', (instance) =>
      @try =>
          child = instance.children.myChild
          grandChild = child.context.children[0]
          expect(grandChild.parent).to.equal child
          expect(child.parent).to.equal instance.ctrl
      done()


  it 'does not have parent', (done) ->
    Test.insert 'foo', (instance) =>
      @try =>
          expect(instance.parent).to.be.undefined
      done()



# ----------------------------------------------------------------------



describe 'Instance: appendChild', ->
  afterEach -> Test.tearDown()

  it 'appends a child control directly within the parent', (done) ->
    Test.insert 'foo', (instance) =>
      ctrl = instance.ctrl
      childCtrl = instance.appendCtrl 'foo', null
      @try =>
          expect(instance.el('> .foo').length).to.equal 1
          expect(childCtrl.parent).to.equal ctrl
          expect(childCtrl.context.parent).to.equal instance
          expect(instance.children[0]).to.equal childCtrl
      done()



# ----------------------------------------------------------------------



describe 'Instance: findChildren', ->
  afterEach -> Test.tearDown()

  it 'finds no children when no filter is passed (empty array)', (done) ->
    Test.insert 'deep', (instance) =>
      @try =>
        expect(instance.findChildren()).to.eql []
      done()


  it 'finds children by full type-name', (done) ->
    Test.insert 'deep', (instance) =>
      @try =>
          result = instance.findChildren(type:'deep-child')
          expect(result.length).to.equal 1
          expect(result[0].type).to.equal 'deep-child'
      done()


  it 'finds children by partial type-name (suffix)', (done) ->
    Test.insert 'deep', (instance) =>
      @try =>
          result = instance.findChildren(type:'-child')
          expect(result.length).to.equal 1
          expect(result[0].type).to.equal 'deep-child'
      done()


  it 'finds multiple children witht he same type-name', (done) ->
    Test.insert 'deep', (instance) =>
      @try =>
          result = instance.findChildren(type:'foo')
          expect(result.length).to.equal 2
          expect(result[0].type).to.equal 'foo'
          expect(result[1].type).to.equal 'foo'
      done()


  it 'finds children by ID', (done) ->
    Test.insert 'deep', (instance) =>
      @try =>
          result = instance.findChildren(id:'myFoo')
          expect(result.length).to.equal 1
          expect(result[0].type).to.equal 'foo'
          expect(result[0].id).to.equal 'myFoo'
      done()


  it 'finds children by function filter', (done) ->
    Test.insert 'deep', (instance) =>
      @try =>
          result = instance.findChildren (ctrl) -> true if ctrl.id is 'myFoo'
          expect(result.length).to.equal 1
          expect(result[0].type).to.equal 'foo'
      done()


  it 'finds no children with function filter', (done) ->
    Test.insert 'deep', (instance) =>
      @try =>
          result = instance.findChildren (ctrl) ->
          expect(result).to.eql []
      done()


# ----------------------------------------------------------------------


describe 'Instance: findChild', ->
  afterEach -> Test.tearDown()

  it 'finds no child when no filter is passed (undefined)', (done) ->
    Test.insert 'deep', (instance) =>
      @try =>
        expect(instance.findChild()).to.eql undefined
      done()


  it 'finds first child by type-name', (done) ->
    Test.insert 'deep', (instance) =>
      @try =>
          fooCtrls = instance.findChildren(type:'foo')
          result = instance.findChild(type:'foo')
          expect(result.type).to.equal 'foo'
          expect(result).to.equal fooCtrls[0]
      done()


  it 'finds child by ID', (done) ->
    Test.insert 'deep', (instance) =>
      @try =>
          result = instance.findChild(id:'myFoo')
          expect(result.id).to.equal 'myFoo'
      done()

  it 'finds child by function filter', (done) ->
    Test.insert 'deep', (instance) =>
      @try =>
          result = instance.findChild (ctrl) -> true if ctrl.id is 'myFoo'
          expect(result.id).to.equal 'myFoo'
      done()

  it 'finds no child with function filter', (done) ->
    Test.insert 'deep', (instance) =>
      @try =>
          result = instance.findChild (ctrl) ->
          expect(result).to.eql undefined
      done()



