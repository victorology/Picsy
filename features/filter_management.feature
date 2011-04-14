Feature: Manage filter
  In order to manage filter
  As a user
  I wants to filter items through category and item type
  
  Scenario: List of items in various category & item type
    Given I have complete data
    When I am on the home page
    And I follow "Gangnam"
    Then I should see "All » Seoul » Gangnam"
    And I should see "음식 2 » 아주 맛있는 음식, 그것은 건강에 좋은 아주 맛있는 음식, 그것은 건강에 좋은"
    
    When I am on the home page
    And I follow "Stuff"
    Then I should see "All » Stuff"
    And I should see "Panasonic"

    When I follow "Gangnam"
    Then I should see "All » Stuff » Seoul » Gangnam"
    And I should see "Panasonic"
    And I should see "Nintendo" 
 