Package.describe({
  name: 'respondly:ctrl',
  summary: 'Logical UI-control abstraction around blaze',
  version: '1.0.0',
  git: 'https://github.com/Respondly/meteor-ctrl.git'
});



Package.on_use(function (api) {
  api.use('http', ['client', 'server']);
  api.use(['templating', 'ui', 'spacebars'], 'client');
  api.use(['coffeescript']);
  api.use(['respondly:util']);
  api.export(['Ctrl', 'Ctrls', 'Util']);

  // Generated with: github.com/philcockfield/meteor-package-paths
  api.add_files('client/tmpl/tmpl.html', 'client');
  api.add_files('client/ns.js', 'client');
  api.add_files('client/api.coffee', 'client');
  api.add_files('client/control/control.coffee', 'client');
  api.add_files('client/control/definition.coffee', 'client');
  api.add_files('client/control/instance.coffee', 'client');
  api.add_files('client/tmpl/tmpl.coffee', 'client');

});



Package.on_test(function (api) {
  api.use(['mike:mocha-package@0.4.7', 'coffeescript']);
  api.use(['templating', 'ui', 'spacebars'], 'client');
  api.use(['respondly:util']);
  api.use('respondly:ctrl');

  // Generated with: github.com/philcockfield/meteor-package-paths
  api.add_files('tests/client/ctrl/sample.html', 'client');
  api.add_files('tests/client/_init.coffee', 'client');
  api.add_files('tests/client/ctrl/sample.coffee', 'client');
  api.add_files('tests/client/ctrl/sample.styl', 'client');
  api.add_files('tests/client/control.coffee', 'client');
  api.add_files('tests/client/dom.coffee', 'client');
  api.add_files('tests/client/instance-callbacks.coffee', 'client');
  api.add_files('tests/client/instance-children.coffee', 'client');
  api.add_files('tests/client/instance-deps.coffee', 'client');
  api.add_files('tests/client/instance-dom.coffee', 'client');
  api.add_files('tests/client/instance-events.coffee', 'client');
  api.add_files('tests/client/instance.coffee', 'client');
  api.add_files('tests/client/render-tmpl.coffee', 'client');

});
