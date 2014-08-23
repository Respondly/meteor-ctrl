describe 'Instance: parent / children', ->
  afterEach -> Test.tearDown()

  it 'has children', (done) ->
    Test.insert 'deep', (instance) =>
      @try =>
          children = instance.children
          expect(instance.parent).to.be.undefined

          # Children array.
          expect(children.length).to.equal 3
          expect(children[0].type).to.equal 'foo'
          expect(children[1].type).to.equal 'deepChild'
          expect(children[2].type).to.equal 'foo'

          # Children by "id".
          expect(children.myChild).to.equal children[1]
          expect(children.myFoo).to.equal instance.children[2]

      done()


  it 'has parent', (done) ->
    Test.insert 'deep', (instance) =>
      @try =>
          child = instance.children.myChild
          grandChild = child.children[0]
          expect(grandChild.parent).to.equal child
          expect(child.parent).to.equal instance
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
      childCtrl = instance.appendCtrl 'foo', null
      @try =>
          expect(instance.el('> .foo').length).to.equal 1
          expect(childCtrl.parent).to.equal instance.ctrl
          expect(childCtrl.context.parent).to.equal instance
          expect(instance.children[0]).to.equal childCtrl.context
          expect(instance.ctrl.children[0]).to.equal childCtrl
      done()


