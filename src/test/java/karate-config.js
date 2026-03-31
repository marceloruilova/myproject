function fn() {
  var env = karate.env; // get system property 'karate.env'
  karate.log('karate.env system property was:', env);
  if (!env) {
    env = 'dev';
  }
  var config = {
    env: env,
    baseUrl: 'https://dummyjson.com'
  }
  if (env == 'dev') {
    config.baseUrl = 'https://dummyjson.com';
  } else if (env == 'e2e') {
    config.baseUrl = 'https://dummyjson.com';
  }
  return config;
}