Feature: Authentication API - Test Cases TC-01 through TC-06
  # Target API: https://reqres.in
  # Auth endpoint: POST /api/login  |  Protected: GET /api/users/2  |  Create: POST /api/users

  Background:
    * url baseUrl

  # TC-01: Valid credentials return 200 with a non-null, non-empty token.
  Scenario: TC-01 - Successful login with valid credentials
    Given path '/api/login'
    And request { email: 'eve.holt@reqres.in', password: 'cityslicka' }
    When method POST
    Then status 200
    And match response contains { token: '#string' }
    And assert response.token != null
    And assert response.token.length > 0

  # TC-02: Missing password field returns 400 with error "Missing password".
  Scenario: TC-02 - Failed login without password field
    Given path '/api/login'
    And request { email: 'peter@klaven' }
    When method POST
    Then status 400
    And match response.error == 'Missing password'

  # TC-03 (Edge Case): Empty string password should be rejected with 400.
  # KNOWN BUG in reqres.in: returns 200. Test intentionally fails to surface the bug.
  Scenario: TC-03 - Login with empty password string
    Given path '/api/login'
    And request { email: 'eve.holt@reqres.in', password: '' }
    When method POST
    * def actualStatus = responseStatus
    * if (actualStatus == 200) karate.log('SECURITY BUG: Empty password was accepted as valid!')
    * if (actualStatus == 400) karate.log('OK: Empty password correctly rejected with 400')
    Then status 400
    And match response.error == '#string'

  # TC-04: Invalid email format should be rejected with 400.
  # KNOWN BUG in reqres.in: returns 200. Test intentionally fails to surface the bug.
  Scenario: TC-04 - Login with invalid email format
    Given path '/api/login'
    And request { email: 'invalid-email', password: '123' }
    When method POST
    * def actualStatus = responseStatus
    * if (actualStatus != 400) karate.log('BUG DETECTED: Invalid email format was accepted - status: ' + actualStatus)
    Then status 400
    And match response.error == '#string'

  # TC-05: GET /api/users/2 without token should return 401.
  # KNOWN INCONSISTENCY: reqres.in returns 200 — test intentionally fails to expose the bug.
  Scenario: TC-05 - Access protected endpoint without auth token
    Given path '/api/users/2'
    When method GET
    * if (responseStatus == 200) karate.log('SECURITY BUG: /api/users/2 returned 200 with no token. Expected 401 Unauthorized.')
    * if (responseStatus == 401) karate.log('OK: Endpoint correctly returned 401 Unauthorized.')
    Then status 401

  # TC-06: Full flow - login -> save token -> create user WITHOUT token.
  # Validates 201 with id + createdAt. Detects auth inconsistency on /api/users.
  Scenario: TC-06 - Full flow: login then create user (detect auth inconsistency)
    # Step 1: Login and capture token
    Given path '/api/login'
    And request { email: 'eve.holt@reqres.in', password: 'cityslicka' }
    When method POST
    Then status 200
    * def token = response.token
    * karate.log('Step 1 - Token obtained:', token)

    # Step 2: Create user WITHOUT sending the token (exposes auth inconsistency)
    Given path '/api/users'
    And request { name: 'morpheus', job: 'leader' }
    When method POST
    Then status 201
    And match response contains { id: '#string' }
    And match response contains { createdAt: '#string' }
    * karate.log('Step 2 - User created without token. API INCONSISTENCY: /api/users does not enforce authentication.')
