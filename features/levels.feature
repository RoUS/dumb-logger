Feature: Test reporting using numeric levels
  In order to use the basic functionality of the DumbLogger class
  A developer
  Should be able to manipulate all of the logger's attributes

  Background:
    Given I have a DumbLogger object
    And I set attribute 'sink' to :$stderr
    And I set attribute level_style to DumbLogger::USE_LEVELS
    And I set attribute loglevel to 5

  Scenario: Default Level-0 1-liner text always gets sent and returns 0)
    When I invoke the logger with ("a message")
    Then stderr should contain exactly "a message\n"
    And the return value should be 0

  Scenario: Default Level-0 multi-line text always gets sent and returns 0
    When I invoke the logger with ("a message line 1","and now line 2")
    Then stderr should contain exactly "a message line 1\nand now line 2\n"
    And the return value should be 0

  Scenario: Explicit level-too-high 1-liner text is ignored and returns nil
    When I invoke the logger with (6, "a message")
    Then stderr should contain exactly ""
    And the return value should be nil

  Scenario: Explicit level-too-high multi-line text is ignored and returns nil
    When I invoke the logger with (6, "a message line 1", "and now line 2")
    Then stderr should contain exactly ""
    And the return value should be nil

