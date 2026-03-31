Feature: Login API - Autenticación de usuarios

  Background:
    * url baseUrl

  # TC-01: Valida que el endpoint /api/login devuelve status 200 y un token
  # no nulo y no vacío al enviar credenciales válidas.
  Scenario: TC-01 - Login exitoso con credenciales válidas
    Given path '/api/login'
    And request { email: 'eve.holt@reqres.in', password: 'cityslicka' }
    When method POST
    Then status 200
    And match response contains { token: '#string' }
    And assert response.token.length > 0
