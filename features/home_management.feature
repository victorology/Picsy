Feature: Manage home
  In order to manage Home Page
  As a user
  I wants to see Home Page
  
  Scenario: List of items in Home Page
    Given I have complete data
    When I am on the home page
    And I should see "Seoul"
    Then I should see "멋진 물건, 싼 가격, 멋진 물건, 싼 가격"
