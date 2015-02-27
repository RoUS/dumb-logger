@masks
Feature: Test reporting using bitmasks
  In order to use the basic functionality of the DumbLogger class
  A developer
  Should be able to assign meaning to bits in a mask

  Background:
    Given I have a DumbLogger object
    And I set attribute 'sink' to :$stderr
    And I set attribute level_style to DumbLogger::USE_BITMASK
    And I set attribute loglevel to 0b01101

  Scenario: Confirm that :logmask dominates :loglevel
    When I create a DumbLogger object using:
      """
      {
        :level_style	=> DumbLogger::USE_BITMASK,
        :loglevel	=> 10,
        :logmask	=> 20,
      }
      """
    Then the loglevel should be 20
    Then the logmask should be 20

  Scenario: Default Level-0 1-liner text always gets sent and returns 0)
    When I invoke the logger with ("a message")
    Then the return value should be 0
    And stderr should contain exactly "a message\n"

  Scenario: Default Level-0 multi-line text always gets sent and returns 0
    When I invoke the logger with ("a message line 1","message line 2")
    Then the return value should be 0
    And stderr should contain exactly:
      """
      a message line 1
      message line 2

      """
      #
      # Note the final blank line above indicating the trailing newline
      #

  Scenario: Explicit out-of-mask message gets ignored and returns nil
    When I invoke the logger with (0b10010, "a message")
    Then the return value should be nil
    And stderr should contain exactly ""

  Scenario: Explicit out-of-mask multi-line text is ignored and returns nil
    When I invoke the logger with (0b10010, "message line 1", "message line 2")
    Then the return value should be nil
    And stderr should contain exactly ""

  Scenario: Explicit in-mask message is sent and the matching mask returned
    When I invoke the logger with (0b10111, "a message")
    Then the return value should be 0b00101
    And stderr should contain exactly "a message\n"

