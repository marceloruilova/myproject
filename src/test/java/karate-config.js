function fn() {
  var env = karate.env; // get system property 'karate.env'
  karate.log('karate.env system property was:', env);
  if (!env) {
    env = 'dev';
  }
  var apiKey = java.lang.System.getenv('REQRES_API_KEY');
  if (!apiKey) {
    karate.log('WARNING: REQRES_API_KEY env variable is not set. Requests to /api/* will fail with 401.');
  }
  var config = {
    env: env,
    baseUrl: 'https://reqres.in',
    reqresApiKey: apiKey
  }
  if (env == 'dev') {
    config.baseUrl = 'https://reqres.in';
  } else if (env == 'e2e') {
    config.baseUrl = 'https://reqres.in';
  }
  return config;
}