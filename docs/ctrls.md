# Ctrl

The `Ctrl` namespace provides a principled way of declaring Blaze
templates optimized for creating UI widgets with formal API's, along
with a number of helpers and conventions that makes creating
modular, re-usable UI controls easy.

A control is simply a wrapper around a Blaze template, so anything
you can do with Blaze is available to you.

#### MVVM Architectural Pattern
The logic within a UI control can be thought of loosely as a "view-model,"
that is to say, when working with `models` (ie. a Mongo document) the
code within the control provides the nuanced behavior of the `view`
as well as translating the pure data of the `model` to a format
that is desirable for the `view` to work with.  This is sometimes referred to as the `view-model` from the `MVVM` variant of `MVC` architectural pattern ([ref](http://en.wikipedia.org/wiki/Model_View_ViewModel)).


## Parts
There are three main parts involved in a `Ctrl`:

1. **CtrlDefinition** -
    The class definition of the control.

2. **CtrlInstance** - The internal instance that is created when the control is rendered within the DOM.  This provides access to all internal state, lifecycle callbacks, and is the `this` context for functions declared on the `CtrlDefinition`.

3. **Ctrl** - The public API of the control.  This is the conceptually clean API that you publish to external parties as the formal way to manipulate the control.  This is declared within the `api` subset of the definition.


## Getting Started
The remainder of this document will walk through the creation of a sample `Ctrl` unpacking the main concepts associated with controls.

Let's start by creating a `Ctrl` with a type name of `my-sample`.  To do this, navigate to the command-line to the parent folder where you the control to live, and run the command:

    rt new ctrl my-sample

Now let's host that control in the **UI Harness** for easy testing.  You can learn how to do this [here](https://github.com/Respondly/meteor-packages-private/blob/c4f69c1c29b3af0f48ef4db07e68ad521aeaa98d/server/docs/ui-harness.md).

    describe 'My Sample Ctrl', ->
      before ->
        @title true
        @load 'my-sample'




## The Ctrl Definition
Three files were generated that make up the control: `.coffee`, `.html` and `.styl`.  The `type` is the name of the corresponding template.

#### Code: my-sample.coffee

      Ctrl.define
        'my-sample':
          init: ->
          ready: ->
          destroyed: ->
          model: ->
          api: {}
          helpers: {}
          events: {}


Typically the root element of the control's template has a CSS `class`
name that matches the `type` name.  In this way the control
is a complete, modular, isolated unit with it's unique
type name.

#### Template: my-sample.html

      <template name='my-sample'>
        <div class='my-sample'>
          <code>{{instance}}</code>
        </div>
      </template>


#### CSS: my-type.styl
We use the Stylus CSS pre-processor, however the control system is
not dependent upon Stylus per se.


      .my-type
        background $RED



## Lifecycle
You manage the lifecycle of the control through three lifecycle callbacks.

      Ctrl.define
        'my-sample':
          init: ->
          ready: ->
          destroyed: ->


#### Init
Invoked when the control is first initialised, but is not yet rendered in the DOM.  Preform any initial setup of the control here, especially if initial values are required by `helper` functions, as these will be used by the template as it is rendered into the DOM.

#### Ready
Invoked as soon as the control has rendered into the DOM.  Perform initial setup here if you need access to DOM elements, for example:

    Ctrl.define
      'my-sample':
        ready: ->
          @el('.foo').toggleClass('hidden', false)


#### Destroyed
Invoked when the control is removed from the DOM. Use this callback to clean up any state and release any resources you may be holding onto.

Destroyed is related to the `dispose` method and the corresponding `isDisposed` property.  Calling `dispose() ` on a control will destroy it, and remove it from the DOM.

Resources that are automatically managed by the control are released when the control is destroyed.  These include:

1. Releasing `Deps` handles that were setup using `@autorun`
2. Disposing of the `ReactiveHash` that holds `@prop` values.
3. Disposing of all child controls.


## Helpers
Helpers work the same as Template helpers in Blaze.  Declare a function helper function, and then reference from a template:

#### Code

    Ctrl.define
      'my-sample':
        helpers:
          now: -> new Date().format()


#### Template

    <template name='my-sample'>
      <div class='my-sample'>
        {{ now }}
      </div>
    </template>


Some default helper functions that are automatically provided by the control are:

- `{{instance}}` - Outputs the type and UID of the control.
- `{{uid}}` - Outputs the UID (Unique ID) of the control.
- `{{api}}` - Access to the public API properties.
- `{{options}}` - The arguments passed to the control.
- `{{model}}` - Access to the internal `model` method.


## Events
Events work the same as events do on Blaze templates:

#### Code

    Ctrl.define
      'my-sample':
        events:
          'click .run': (e) -> console.log '!! Run clicked'

#### Template

    <template name='my-sample'>
      <div class='my-sample'>
        <button class='run'>Run Now</button>
      </div>
    </template>




## Inserting a Control within a Template
Insert the control using the `{{> ctrl}}` declaration specifying which type, for example:

    <template>
      <div>
        {{> ctrl type='my-sample' }}
      </div>
    </template>

### Passing Options (Named Arguments)
Pass named arguments to the control like this:

        {{> ctrl type='my-sample'  color='red' }}

These will be available within the `CtrlInstance` on the `@options` object.

There are two special named arguments:

- `data`
- `id`

#### Data
If you have an object that represents the data for the control, pass it using the `data` attribute:

        {{> ctrl type='my-sample'  data=myData }}

This will be available within the `CtrlInstance` on the `@data` object.

#### ID
You may also like to give the control an ID for easy access within the parent control.

      <template name='my-parent'>
        <div class='my-parent'>
          {{> ctrl type='my-sample' id='myHeader' }}
        </div>
      </template>

From within the parent control, the child control will now be available as a named property on the `children` array:

    Ctrl.define
      'my-parent':
        ready: ->
          headerCtrl = @children.myHeader

Note that the ID is scoped to the parent only, meaning you can reuse ID's within different controls without fear of conflict.  If you require a unique ID for a control, see the `hid` property.


## DefaultValue
Default values can be inferred using the `defaultValue` function.  This function first looks at the `@options` object, then at the `@data` object, and finally if the value is found on neither, it returns a specified default value.

    Ctrl.define
      'my-parent':
        ready: ->
          color = @defaultValue('color', 'red'')

In this case `red` would be returned if a color had not be specified on either the data or the options.


## Parent and Children
One of the strengths of the `Ctrl` system is that it provides complete traversal of the logical hierarchy of UI controls.

#### Parent
Every `CtrlInstance` has a parent `CtrlInstance`, and the corresponding public `Ctrl` has a reference to it's parent `Ctrl`.

Traversing up the hierarchy can be achieved using the `ancestor` and `closest` methods, which conceptually map to their namesakes on jQuery, but return logical UI controls rather than DOM elements.

In the following example `myCtrl` would be the first control in the parent hierarchy of type `my-root`.

    Ctrl.define
      'my-sample':
        ready: ->
          myCtrl = @ancestor(type:'my-root')


### Children
A control maintains an array of it's children.  If any of the children have been given explicit `id` arguments, then these are stored as attributes on the array.


### Filtering Children
The helper methods `findChildren` and `firstChild` allow you to traverse the `children` collection with common filters.

#### findChildren
Retrieves an array.

    # Find by type-name.
    items = instance.findChildren(type:'deep-child')

    # Find by partial type-name.
    items = instance.findChildren(type:'-child')

    # Find by function filter.
    items = instance.findChildren (ctrl) -> true if ctrl.id is 'myFoo'

#### findChild
Finds the first matching child.

    # Find by type-name.
    childCtrl = instance.findChild(type:'deep-child')

    # Find by partial type-name.
    childCtrl = instance.findChild(type:'-child')

    # Find by function filter.
    childCtrl = instance.findChild (ctrl) -> true if ctrl.id is 'myFoo'



## Prop (Reactive)
Not only do UI controls handle data from models (Mongo documents) but they can maintain their own state.  This is what makes them powerful tools for implementing MVVM.

One of the main ways non-model related state is stored and accessed within the control is via the `@prop` helper function, which give you access to a `ReactiveHash` for the control.

For example, the following is a control with a public API that has a `color` property:

    Ctrl.define
      'my-sample':
        api:
          color: (value) -> @prop 'color', value, default:'red'

To read the value, the `color` function is called with no argument.  To write to the property, pass the value as an argument:

    # Read.
    myCtrl.color() # <== returns 'red'

    # Write.
    myCtrl.color('blue')
    myCtrl.color() # <== returns 'blue'

#### Default value
Note that the key being passed to the `@prop` method is the same as the public property name `color`.  This is important as this `@prop` function uses `@defaultValue` behind the scenes to determine what value to use if none has been set yet.  So in the example above, if there was not a `color` attribute on either the `@options` or the `@data` then `red` would be returned.

#### OnlyOnChange
By default, the `@prop` function will only cause reactive callbacks to run when a new distinct value is written to it.  In the following example, the `autorun` callback would only run once, as the second time the `color` property is written to, that value has not changed.

    Deps.autorun =>
      console.log myCtrl.color()

    myCtrl.color('green')
    Deps.afterFlush ->
      myCtrl.color('green')

This is important because often times changes to reactive state incurs expensive recalculations and DOM redraws.  You should always be able to write to a control property safe in the knowledge that you don't have to perform checks that the value really has changed before committing it to the control.


## Autorun
The control provides an `@autorun` helper for times where you want to setup a function to re-run every time a reactive value changes.  For example:

    Ctrl.define
      'my-sample':
        ready: ->
          @autorun =>
              el = @el()
              el.toggleClass('is-red', @api.color() is 'red')

        api:
          color: (value) -> @prop 'color', value, default:'red'

This `@autorun` will re-run every time `color` changes and in this case toggle a CSS class on the root element.


Use `@autorun` within a control, rather than `Deps.autorun` as the control keeps track of the autorun handlers and stops them when the control is disposed.


## Model
The `model` function provides a common (but optional) way of returning the logical representation of data for the control.  This may, or may not, be the exact data or model that was passed into the control, but following MVVM may be a UI centric abstraction of it.

#### Template
A Mongo document ID is passed into the control as data:

    <template>
      <div>
        {{> ctrl type='my-sample' data=documentId }}
      </div>
    </template>

#### Code

    Ctrl.define
      'my-sample':
        model: -> MyModel.findOne(@data)

        helpers:
          title: -> @model().title()

The `model` function uses the document ID passed into `@data` and looks up the corresponding model.  This model is in turn used within a helper function.


## AppendCtrl
At times, it is convenient to programmatically append a child control.  To do this pass a control definition to the `appendCtrl` method:

    Ctrl.define
      'my-root':
        api:
          showEditor: ->
            ctrl = @appendCtrl('my-editor', '.container')
            ctrl.onReady -> # Perform additional setup, etc.

This example inserts a control as the result of a public API method.  It passes the `type` to insert, and a CSS selector of the DOM element within the control to insert the control within.

See the `appendCtrl` method declaration on `CtrlInstance` for more details.



## Render from Helper
Sometimes you want to render a control into a template as the result of a helper function.  Often this is the case when you need to dynamically decide what control should be inserted, or whether the control should be inserted at all.

When doing this, you will typically want to hold a reference to the control somewhere.  To achieve this use `{{> render}}`

####Template

      <template>
        <div>
          {{> render ctrl=childDef }}
        </div>
      </template>

Here `{{> render}}` takes definition object that at minimum contains a `type`, and will often have a `data` object.

You can also add any arbitrary properties, and they will be applied to the control as `@options`.

#### Code

    Ctrl.define
      'my-root':
        helpers:
          childDef: ->
            def =
              type: 'my-sample'
              data: { foo:123 }
              id:   'myChild'
              arg1: 'option'
              onInit: (ctrl) -> @childCtrl = ctrl
              onReady: (ctrl) ->
              onDestroyed: ->

Notice the `onInit` and `onReady` callbacks.  Use these to optionally store a hard reference to the child control or perform final initialisation when the control has surfaced in the DOM.

Return nothing (`null / undefined`) from the function when in a state where the child control should not be rendered.

