describe 'Instance (events)', ->
  instance = null
  ctrl = null
  afterEach -> Test.tearDown()
  beforeEach (done) ->
    Test.insert 'eventTest', (i) =>
          instance = i
          ctrl = instance.ctrl
          done()

  it 'does not have an events object by default', ->
    expect(instance.__internal__.events).to.equal undefined

  it 'stores an [Events] objects after "on" is called',  ->
    instance.on 'my:events', (j, e) ->
    expect(instance.__internal__.events).to.be.an.instanceOf Util.Events

  it 'listens to an event "on" the [instance]',  ->
    count = 0
    args = null
    instance.on 'my:event', (j, e) ->
        count += 1
        args = e
    instance.trigger('my:event', { foo:123 })
    expect(args).to.eql { foo:123 }
    expect(count).to.equal 1

  it 'listens to an event "on" the [ctrl]', ->
    count = 0
    ctrl.on 'my:event', -> count += 1
    instance.trigger('my:event')
    expect(count).to.equal 1

  it 'removes an event "off" the [instance]', ->
    countA = 0
    countB = 0
    handlerA = (j, e) -> countA += 1
    handlerB = (j, e) -> countB += 1
    instance.on 'a', handlerA
    instance.off 'a', handlerA
    instance.on 'b', handlerB

    instance.trigger 'a'
    instance.trigger 'b'
    expect(countA).to.equal 0
    expect(countB).to.equal 1

  it 'removes all events "off" the [instance]', ->
    countA = 0
    countB = 0
    handlerA = (j, e) -> countA += 1
    handlerB = (j, e) -> countB += 1
    instance.on 'a', handlerA
    instance.on 'b', handlerB
    instance.off()

    instance.trigger 'a'
    instance.trigger 'b'
    expect(countA).to.equal 0
    expect(countB).to.equal 0

  it 'removes all events "off" the [ctrl]', ->
    count = 0
    ctrl.on 'my:event', -> count += 1
    ctrl.off()
    instance.trigger('my:event')
    expect(count).to.equal 0

  it 'removes all events when disposed', ->
    count = 0
    ctrl.on 'my:event', -> count += 1
    ctrl.dispose()
    instance.trigger('my:event')
    expect(count).to.equal 0
