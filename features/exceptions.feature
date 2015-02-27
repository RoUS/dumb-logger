@exceptions
Feature: Test that all the things that *should* raise exceptions -- do.

  Background:
    Given I have a DumbLogger object

  Scenario: Test giving the contructor incorrect arguments
    When I create a DumbLogger object using [1,2,3]
    Then it should raise an exception of type ArgumentError

  Scenario: Test setting labels with a non-hash
    When I label loglevels with Object
    Then it should raise an exception of type ArgumentError

  Scenario: Test setting labels with a bogus hash
    When I label loglevels with {:foo=>Object}
    Then it should raise an exception of type ArgumentError

  Scenario: Test setting the logging level to something bogus
    When I set attribute loglevel to Object
    Then it should raise an exception of type ArgumentError

  Scenario: Test setting the level-style to something bogus
    When I set attribute level_style to Object
    Then it should raise an exception of type ArgumentError
