@output
@file
Feature: Test the output generated and sent to a file
  In order to use the basic functionality of the DumbLogger class
  A developer
  Should be able to depend on the correct output being sent to a file.

  Background:
    Given I have a DumbLogger object
    And I set attribute 'sink' to 'tmp/aruba/test-log'
    And I set attribute level_style to DumbLogger::USE_LEVELS
    And I set attribute loglevel to 5

  Scenario: Append to an empty file
    Given an empty file named "test-log-alt"
    Then the file "test-log-alt" should contain exactly:
      """
      """
    And I create a DumbLogger object using:
      """
      {
        :level_style    => DumbLogger::USE_BITMASK,
        :loglevel       => 10,
        :sink		=> 'tmp/aruba/test-log-alt',
        :append		=> true,
      }
      """
    And I invoke the logger with ("a message")
    Then the return value should be 0
    And the file "test-log-alt" should contain exactly:
      """
      a message

      """

  Scenario: Append to an existing file
    Given a file named "test-log-alt" with:
      """
      existing content

      """
    Then the file "test-log-alt" should contain exactly:
      """
      existing content

      """
    Then I create a DumbLogger object using:
      """
      {
        :level_style    => DumbLogger::USE_BITMASK,
        :loglevel       => 10,
        :sink		=> 'tmp/aruba/test-log-alt',
        :append		=> true,
      }
      """
    And I invoke the logger with ("a message")
    Then the return value should be 0
    And the file "test-log-alt" should contain exactly:
      """
      existing content
      a message

      """

  Scenario: Truncate an existing file
    Given a file named "test-log-alt" with:
      """
      existing content

      """
    Then the file "test-log-alt" should contain exactly:
      """
      existing content

      """
    Then I create a DumbLogger object using:
      """
      {
        :level_style    => DumbLogger::USE_LEVELS,
        :loglevel       => 10,
        :sink		=> 'tmp/aruba/test-log-alt',
        :append		=> false,
      }
      """
    And I invoke the logger with ("a message")
    Then the return value should be 0
    And the file "test-log-alt" should contain exactly:
      """
      a message

      """

  Scenario: Append to an existing file w/o seeking-to-EOF at each write
    skip
    #
    # Having trouble getting *real* asynchronicity in the output, so
    # let's skip this until we can do it reliably.
    #
#    Given a file named "test-log-alt" with:
#      """
#      existing content
#
#      """
#    Then the file "test-log-alt" should contain exactly:
#      """
#      existing content
#
#      """
#    Then I create a DumbLogger object using:
#      """
#      {
#        :level_style    => DumbLogger::USE_BITMASK,
#        :loglevel       => 10,
#        :sink		=> 'tmp/aruba/test-log-alt',
#        :append		=> true,
#        :seek_to_eof	=> false,
#      }
#      """
#    And I invoke the logger with ("a message")
#    And I run system("echo 'text added asynchronously' >> tmp/aruba/test-log-alt")
#    Then the file "test-log-alt" should contain exactly:
#      """
#      existing content
#      a message
#      text added asynchronously
#
#      """
#    And I invoke the logger with ("another message")
#    Then the file "test-log-alt" should contain exactly:
#      """
#      existing content
#      a message
#      another message
#
#      """

  Scenario: Test switching to a different sink
    When I invoke the logger with ("a message")
    And I set the sink to :$stderr
    And I invoke the logger with ("another message")
    Then the file "test-log" should contain exactly:
      """
      a message

      """
    And stderr should contain exactly "another message\n"

  Scenario: Test a simple message sent to a file
    When I invoke the logger with ("a message")
    Then the return value should be 0
    And I invoke method "flush"
    Then the file "test-log" should contain exactly:
      """
      a message

      """
    And stderr should contain exactly ""
    And stdout should contain exactly ""

  Scenario: Multi-line message sent to file
    When I invoke the logger with ("line 1","line 2")
    Then the return value should be 0
    And the file "test-log" should contain exactly:
      """
      line 1
      line 2

      """

  Scenario: Single-line message with no newline
    When I invoke the logger with ("a message", :no_nl)
    Then the return value should be 0
    And the file "test-log" should contain exactly:
      """
      a message
      """

  Scenario: Multi-line message with no newline
    When I invoke the logger with ("line 1",{:newline=>false},"line 2")
    Then the return value should be 0
    And the file "test-log" should contain exactly:
      """
      line 1
      line 2
      """

