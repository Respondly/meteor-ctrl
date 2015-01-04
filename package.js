Package.describe({
  name: 'respondly:ctrl',
  summary: 'Logical UI-control abstraction around blaze',
  version: '1.0.1',
  git: 'https://github.com/Respondly/meteor-ctrl.git'
});



Package.onUse(function (api) {
  // api.versionsFrom('1.0');
  api.use('http', ['client', 'server']);
  api.use(['templating', 'ui', 'spacebars'], 'client');
  api.use('coffeescript');
  api.use('respondly:util@1.0.1');
  api.export('Ctrl');
  api.export('Ctrls');
  api.export('Util');

  // Generated with: github.com/philcockfield/meteor-package-paths
  api.addFiles('shared/ns.js', ['client', 'server']);
  api.addFiles('server/api.coffee', 'server');
  api.addFiles('client/tmpl/tmpl.html', 'client');
  api.addFiles('client/api.coffee', 'client');
  api.addFiles('client/control/control.coffee', 'client');
  api.addFiles('client/control/definition.coffee', 'client');
  api.addFiles('client/control/instance.coffee', 'client');
  api.addFiles('client/tmpl/tmpl-ctrl.coffee', 'client');
  api.addFiles('client/tmpl/tmpl-render-each.coffee', 'client');
  api.addFiles('client/tmpl/tmpl-render.coffee', 'client');

});



Package.onTest(function (api) {
  api.use(['mike:mocha-package@0.4.7', 'coffeescript']);
  api.use(['templating', 'ui', 'spacebars'], 'client');
  api.use(['respondly:util']);
  api.use('respondly:ctrl');

  // Generated with: github.com/philcockfield/meteor-package-paths
  api.addFiles('tests/client/ctrl/sample.html', 'client');
  api.addFiles('tests/client/_init.coffee', 'client');
  api.addFiles('tests/client/ctrl/sample.coffee', 'client');
  api.addFiles('tests/client/ctrl/sample.styl', 'client');
  api.addFiles('tests/client/control.coffee', 'client');
  api.addFiles('tests/client/dom.coffee', 'client');
  api.addFiles('tests/client/instance-callbacks.coffee', 'client');
  api.addFiles('tests/client/instance-children.coffee', 'client');
  api.addFiles('tests/client/instance-deps.coffee', 'client');
  api.addFiles('tests/client/instance-dom.coffee', 'client');
  api.addFiles('tests/client/instance-events.coffee', 'client');
  api.addFiles('tests/client/instance.coffee', 'client');
  api.addFiles('tests/client/render-tmpl.coffee', 'client');

});
