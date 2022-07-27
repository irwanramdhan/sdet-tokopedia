Feature: Create and retrieve order
  Background:
    Given user visit tokopedia as 'user_login'

  Scenario: User able to create and retrieve recently created order
    When user successfully create order
    Then system should retrieve the details of the created order