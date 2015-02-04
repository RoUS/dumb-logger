Feature: Test default attributes and setting/pinging them
  In order to use the basic functionality of the DumbLogger class
  A developer
  Should be able to manipulate all of the logger's attributes

#  Things to test:
#   o constructor
#     - no args
#     - :append => {true,false,bogus}
#     - :level_style => {USE_LEVELS,USE_BITMASK,bogus}
#     - :loglevel => {number,bogus}
#     - :logmask => {number,bogus}
#     - :prefix => {string,bogus}
#     - :sink => {path,IO,bogus}

  Background:
    Given I have a DumbLogger object

  Scenario: Check the defaults
    Then the log-level should be 0
    And the sink should be :$stderr
    And the style should be DumbLogger::USE_LEVELS
    And the prefix should be ''
    And append-mode should be true

  Scenario: Test setting the logging level to an integer
    When I set attribute loglevel to 5
    Then the return value should be 5
    And the log-level should be 5

  Scenario: Test setting the logging level to a float
    When I set attribute loglevel to 5.7
    Then the return value should be 5
    And the log-level should be 5

  Scenario: Test setting the logging level to a string
    When I set attribute loglevel to "5"
    Then the return value should be 5
    And the log-level should be 5

  Scenario: Test setting the logging level to something bogus
    When I set attribute loglevel to Object
    Then it should raise an exception of type ArgumentError
    And the log-level should be 0

  Scenario: Test setting the logging style
    When I set attribute level_style to DumbLogger::USE_BITMASK
    Then the return value should be DumbLogger::USE_BITMASK
    And the style should be DumbLogger::USE_BITMASK

  Scenario: Test setting the prefix
    When I set attribute prefix to 'Testing: '
    Then the return value should be 'Testing: '
    And the prefix should be 'Testing: '

  Scenario: Test turning off append-mode
    When I set attribute append to false
    Then the return value should be false
    And append-mode should be false

  Scenario: Test changing the sink to a path
    When I set attribute 'sink' to '/dev/null'
    Then the return value should be '/dev/null'
    And the sink should be '/dev/null'

  Scenario: Test changing the sink to stdout
    When I set attribute 'sink' to :$stdout
    Then the return value should be :$stdout
    And the sink should be :$stdout

