@output
@stderr
Feature: Test the output generated sent to stderr
  In order to use the basic functionality of the DumbLogger class
  A developer
  Should be able to depend on the correct output being sent to stderr.

  Background:
    Given I have a DumbLogger object
    And I set attribute 'sink' to :$stderr
    And I set attribute level_style to DumbLogger::USE_LEVELS
    And I set attribute loglevel to 5

  Scenario: Single-line message sent to stderr
    When I invoke the logger with ("a message")
    Then the return value should be 0
    And stderr should contain exactly "a message\n"
    And stdout should contain exactly ""

  Scenario: Closing a special sink should return false
    When I invoke method "close"
    Then the return value should be false

  Scenario: Single-line message sent to stdout
    When I set the sink to :$stdout
    And I invoke the logger with ("a message")
    Then the return value should be 0
    And stderr should contain exactly ""
    And stdout should contain exactly "a message\n"

  Scenario: Multi-line message sent to stderr
    When I invoke the logger with ("line 1","line 2")
    Then the return value should be 0
    And stderr should contain exactly "line 1\nline 2\n"
    And stdout should contain exactly ""

  Scenario: Multi-line message sent to stdout
    When I set the sink to :$stdout
    And I invoke the logger with ("line 1","line 2")
    Then the return value should be 0
    And stderr should contain exactly ""
    And stdout should contain exactly "line 1\nline 2\n"

  Scenario: Single-line message with no newline
    When I invoke the logger with ("a message", :no_nl)
    Then the return value should be 0
    And stderr should contain exactly "a message"
    And stdout should contain exactly ""

  Scenario: Single-line message with no newline (alternate 1)
    When I invoke the logger with ("a message", {:newline=>false})
    Then the return value should be 0
    And stderr should contain exactly "a message"
    And stdout should contain exactly ""

  Scenario: Single-line message with no newline (alternate 2)
    When I invoke the logger with ("a message", {:return=>false})
    Then the return value should be 0
    And stderr should contain exactly "a message"
    And stdout should contain exactly ""

  Scenario: Single-line message with :newline overriding :return
    When I invoke the logger with ("a message", {:newline=>false,:return=>true})
    Then the return value should be 0
    And stderr should contain exactly "a message"
    And stdout should contain exactly ""

  Scenario: Multi-line message with no newline
    When I invoke the logger with ("line 1",:no_nl,"line 2")
    Then the return value should be 0
    And stderr should contain exactly "line 1\nline 2"
    And stdout should contain exactly ""

  Scenario: Multi-line message with no newline (alternate 1)
    When I invoke the logger with ("line 1",{:newline=>false},"line 2")
    Then the return value should be 0
    And stderr should contain exactly "line 1\nline 2"
    And stdout should contain exactly ""

  Scenario: Multi-line message with no newline (alternate 2)
    When I invoke the logger with ("line 1",{:return=>false},"line 2")
    Then the return value should be 0
    And stderr should contain exactly "line 1\nline 2"
    And stdout should contain exactly ""

  Scenario: Multi-line message with :newline overriding :return
    When I invoke the logger with ("line 1",{:return=>true,:newline=>false},"line 2")
    Then the return value should be 0
    And stderr should contain exactly "line 1\nline 2"
    And stdout should contain exactly ""

  Scenario: Single-line message with instance prefix
    When I set the prefix to '[instance-prefix] '
    And I invoke the logger with ("a message")
    Then the prefix should be '[instance-prefix] '
    And the return value should be 0
    And stderr should contain exactly "[instance-prefix] a message\n"
    And stdout should contain exactly ""

  Scenario: Multi-line message with instance prefix
    When I set the prefix to '[instance-prefix] '
    And I invoke the logger with ("line 1","line 2")
    Then the prefix should be '[instance-prefix] '
    And the return value should be 0
    And stderr should contain exactly:
      """
      [instance-prefix] line 1
      [instance-prefix] line 2

      """
    And stdout should contain exactly ""

  Scenario: Single-line message with method prefix
    When I invoke the logger with ("a message", :prefix => "[method-prefix] ")
    Then the prefix should be ''
    And the return value should be 0
    And stderr should contain exactly "[method-prefix] a message\n"
    And stdout should contain exactly ""

  Scenario: Multi-line message with method prefix
    When I invoke the logger with ("line 1","line 2",:prefix => "[method-prefix] ")
    Then the prefix should be ''
    And the return value should be 0
    And stderr should contain exactly:
      """
      [method-prefix] line 1
      [method-prefix] line 2

      """
    And stdout should contain exactly ""

  Scenario: Single-line message with differing instance and method prefices
    When I set the prefix to '[instance-prefix] '
    And I invoke the logger with ("a message", :prefix => "[method-prefix] ")
    Then the prefix should be '[instance-prefix] '
    And the return value should be 0
    And stderr should contain exactly "[method-prefix] a message\n"
    And stdout should contain exactly ""

  Scenario: Multi-line message with differing method and instance prefices
    When I set the prefix to '[instance-prefix] '
    And I invoke the logger with ("line 1","line 2",:prefix => "[method-prefix] ")
    Then the prefix should be '[instance-prefix] '
    And the return value should be 0
    And stderr should contain exactly:
      """
      [method-prefix] line 1
      [method-prefix] line 2

      """
    And stdout should contain exactly ""

  Scenario: Single-line message with multiple options
    When I invoke the logger with ("line 1",:newline=>false,:prefix=>"[method-prefix] ")
    Then the prefix should be ''
    And the return value should be 0
    And stderr should contain exactly "[method-prefix] line 1"
    And stdout should contain exactly ""

  Scenario: Multi-line message with method prefix
    When I invoke the logger with ("line 1",{:newline=>false,:prefix=>"[method-prefix] "},"line 2")
    Then the prefix should be ''
    And the return value should be 0
    And stderr should contain exactly "[method-prefix] line 1\n[method-prefix] line 2"
    And stdout should contain exactly ""

