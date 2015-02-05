Feature: Test reporting using labeled levels
  In order to report using different methods,
  A developer
  Should be able to assign labels to loglevels.

  Background:
    Given I have a DumbLogger object
    And I set 'sink' to :$stderr
    And I set 'level_style' to DumbLogger::USE_LEVELS
    And I set 'loglevel' to 5

  Scenario: Assign 'ok' to level 0
    When I label level 0 with name "ok"
    And I invoke the logger with ok("a message")
    Then the return value should be 0
    And stderr should contain exactly "a message\n"

  Scenario: Assign 'ok' to level 0 and 'debug' to level 1
    When I label level 0 with name "ok"
    And I label level 1 with name "debug"
    And I invoke the logger with debug("a message")
    Then the return value should be 1
    And stderr should contain exactly "a message\n"

  Scenario: Assign 'ok' to level 0, 'debug' to 1, and 'silent' to 6
    When I label level 0 with name "ok"
    And I label level 1 with name "debug"
    And I label level 6 with name "silent"
    And I invoke the logger with silent("a message")
    Then the return value should be nil
    And stderr should contain exactly ""

  Scenario: Check the label assignments
    When I label level 0 with name "ok"
    And I label level 1 with name "debug"
    And I label level 6 with name "silent"
    And I query method "labeled_levels"
    Then the return value should be {:debug=>1, :ok=>0, :silent=>6}

