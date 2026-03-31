Feature: Login API - Autenticación de usuarios

  Background:
    * url baseUrl

  # TC-01: Valida que el endpoint /auth/login devuelve status 200 y un accessToken
  # no nulo y no vacío al enviar credenciales válidas.
  Scenario: TC-01 - Login exitoso con credenciales válidas
    Given path '/auth/login'
    And request { username: 'emilys', password: 'emilyspass' }
    When method POST
    Then status 200
    And match response contains { accessToken: '#string' }
    And assert response.accessToken.length > 0
