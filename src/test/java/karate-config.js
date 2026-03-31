function fn() {
  var env = karate.env; // get system property 'karate.env'
  karate.log('karate.env system property was:', env);
  if (!env) {
    env = 'dev';
  }
  var config = {
    env: env,
    baseUrl: 'https://reqres.in'
  }
  if (env == 'dev') {
    config.baseUrl = 'https://reqres.in';
  } else if (env == 'e2e') {
    config.baseUrl = 'https://reqres.in';
  }
  return config;
}