{{flutter_js}}
{{flutter_build_config}}

const appVersion = 'brand-logo-ui-20260805';

if (window._flutter?.buildConfig?.builds) {
  _flutter.buildConfig.builds = _flutter.buildConfig.builds.map((build) => {
    if (build?.mainJsPath === 'main.dart.js') {
      return {
        ...build,
        mainJsPath: `main.dart.js?v=${appVersion}`,
      };
    }

    return build;
  });
}

_flutter.loader.load({
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}},
  },
});
