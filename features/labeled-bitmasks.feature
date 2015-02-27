@labels
@bitmasks
Feature: Test reporting using labeled bitmasks
  In order to report using different methods,
  A developer
  Should be able to assign labels to mask bit patterns.

  Background:
    Given I have a DumbLogger object
    And I set 'sink' to :$stderr
    And I set 'level_style' to DumbLogger::USE_BITMASK
    And I set 'logmask' to 0b0101

  Scenario: Assign 'ok' to level 0
    When I label level 0 with name "ok"
    And I invoke the logger with ok("a message")
    Then the return value should be 0
    And stderr should contain exactly "a message\n"

  Scenario: Assign 'ok' to all-bits-clear and 'debug' to bit 0 alone
    When I label mask 0b0000 with name "ok"
    And I label mask 0b0001 with name "debug"
    And I invoke the logger with debug("a message")
    Then the return value should be 0b0001
    And stderr should contain exactly "a message\n"

  Scenario: Assign 'ok' to mask 0b0000, 'debug' to 0b0001, and 'silent' to 0b1000
    When I label mask 0b0000 with name "ok"
    And I label mask 0b0001 with name "debug"
    And I label mask 0b1000 with name "silent"
    And I invoke the logger with silent("a message")
    Then the return value should be nil
    And stderr should contain exactly ""

  Scenario: Check the label assignments
    When I label mask 0b0000 with name "ok"
    And I label mask 0b0001 with name "debug"
    And I label mask 0b1000 with name "silent"
    And I query method "labeled_levels"
    Then the return value should be {:debug=>1, :ok=>0, :silent=>8}

  Scenario: Check that an array of labels uses the ORed value
    When I label mask 0b0001 with name "bit_zero"
    And I label mask 0b0010 with name "bit_one"
    And I label mask 0b0100 with name "bit_two"
    And I label mask 0b1000 with name "bit_three"
    And I invoke the logger with message([:bit_zero,:bit_three], 'a message')
    Then the return value should be 0b0001
    And stderr should contain exactly "a message\n"
    And I invoke the logger with message([:bit_three,:bit_two], 'a message')
    Then the return value should be 0b0100
    And stderr should contain exactly "a message\n"
    And I invoke the logger with message([:bit_two,:bit_zero], 'a message')
    Then the return value should be 0b0101
    And stderr should contain exactly "a message\n"

  Scenario: Check that an array of labels supercedes an integer value
    When I label mask 0b0001 with name "bit_zero"
    And I label mask 0b0010 with name "bit_one"
    And I label mask 0b0100 with name "bit_two"
    And I label mask 0b1000 with name "bit_three"
    And I set 'logmask' to 1
    And I invoke the logger with message([:bit_three,:bit_one], 'a message', 0)
    Then the return value should be nil
    And stderr should contain exactly ""

