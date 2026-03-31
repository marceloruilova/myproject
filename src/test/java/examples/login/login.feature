Feature: Authentication API - Test Cases TC-01 through TC-06
  # Target API: https://dummyjson.com
  # Auth endpoint: POST /auth/login  |  Protected: GET /auth/me  |  Create: POST /users/add

  Background:
    * url baseUrl

  # TC-01: Valid credentials return 200 with a non-null, non-empty accessToken.
  Scenario: TC-01 - Successful login with valid credentials
    Given path '/auth/login'
    And request { username: 'emilys', password: 'emilyspass' }
    When method POST
    Then status 200
    And match response contains { accessToken: '#string' }
    And assert response.accessToken != null
    And assert response.accessToken.length > 0

  # TC-02: Missing password field returns 400 with an error message.
  Scenario: TC-02 - Failed login without password field
    Given path '/auth/login'
    And request { username: 'emilys' }
    When method POST
    Then status 400
    And match response.message == '#string'

  # TC-03 (Edge Case): Empty string password should be rejected with 400.
  # If this test FAILS (returns 200) -> SECURITY BUG: empty password treated as valid.
  Scenario: TC-03 - Login with empty password string
    Given path '/auth/login'
    And request { username: 'emilys', password: '' }
    When method POST
    * def actualStatus = responseStatus
    * if (actualStatus == 200) karate.log('SECURITY BUG: Empty password was accepted as valid!')
    * if (actualStatus == 400) karate.log('OK: Empty password correctly rejected with 400')
    Then status 400
    And match response.message == '#string'

  # TC-04: Invalid username format should be rejected with 400.
  # If this test FAILS (returns 200) -> BUG: no input format validation enforced.
  Scenario: TC-04 - Login with invalid username format
    Given path '/auth/login'
    And request { username: 'inv@lid!!user##', password: '123' }
    When method POST
    * def actualStatus = responseStatus
    * if (actualStatus != 400) karate.log('BUG DETECTED: Invalid username format was accepted - status: ' + actualStatus)
    Then status 400
    And match response.message == '#string'

  # TC-05: GET /auth/me without Authorization header must return 401.
  # If returns 200 -> SECURITY BUG: protected endpoint accessible without auth.
  Scenario: TC-05 - Access protected endpoint without auth token
    Given path '/auth/me'
    When method GET
    * if (responseStatus == 200) karate.log('SECURITY BUG: /auth/me returned 200 with no token. Expected 401 Unauthorized.')
    * if (responseStatus == 401) karate.log('OK: Endpoint correctly returned 401 Unauthorized.')
    Then status 401

  # TC-06: Full flow - login to capture token, then create a user WITHOUT the token.
  # Validates 201 with id. Detects API inconsistency if no auth is required for /users/add.
  Scenario: TC-06 - Full flow: login then create user (detect auth inconsistency)
    # Step 1: Login and capture token
    Given path '/auth/login'
    And request { username: 'emilys', password: 'emilyspass' }
    When method POST
    Then status 200
    * def token = response.accessToken
    * karate.log('Step 1 - Token obtained:', token)

    # Step 2: Create user WITHOUT sending the token (exposes auth inconsistency)
    Given path '/users/add'
    And request { firstName: 'Morpheus', lastName: 'Leader', age: 30 }
    When method POST
    Then status 201
    And match response contains { id: '#number' }
    * karate.log('Step 2 - User created without token. API INCONSISTENCY: /users/add does not enforce authentication.')
