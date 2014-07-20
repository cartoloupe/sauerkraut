@test
Feature: Some feature

  Background:
    Given a glass jar
    And a heavy stone
    And salt

  Scenario: Cutting the vegetables
    Given some vegetables
    Given a sharp knife
    When start chopping the vegetables
    Then there should be small slices of vegetables

  Scenario: Adding salt and packing
    Given small slices of vegetables
    Given a layer of vegetables is placed in the jar
    And then salt is added
    Given another layer of vegetables is placed in the jar
    And then more salt is added
    Given some garlic is chopped up
    And garlic is layered into the jar
    Given some more vegetables are placed into the jar
    When the jar is nearly full
    Then a stone should be put on top

  Scenario: Ensuring no exposure to air
    Given a jar full of salted vegetables
    When a heavy stone is placed on top
    And eventually the salt draws water out of the vegetables
    Then eventually the water level will be above the vegetables
    And the vegetables should not be exposed to the air

  Scenario: Long term plan
    Given a jar full of salted weighed down vegetables
    When the jar is left in a cool place between 60 and 70 degrees F
    Given about two to four weeks time
    Then the vegetables should ferment

