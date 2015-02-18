@labels
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

  Scenario: Check that an array of labels uses the minimum value
    When I label level 1 with name "one"
    And I label level 2 with name "two"
    And I label level 3 with name "three"
    And I invoke the logger with message([:three,:one], 'a message')
    Then the return value should be 1
    And stderr should contain exactly "a message\n"
    And I invoke the logger with message([:three,:two], 'a message')
    Then the return value should be 2
    And stderr should contain exactly "a message\n"
    And I invoke the logger with message([:three,:two], 'a message', 99)
    Then the return value should be 2
    And stderr should contain exactly "a message\n"

  Scenario: Check that an array of labels supercedes an integer valu
    When I label level 1 with name "one"
    And I label level 2 with name "two"
    And I label level 3 with name "three"
    And I set 'loglevel' to 1
    And I invoke the logger with message([:three,:two], 'a message', 0)
    Then the return value should be nil
    And stderr should contain exactly ""

