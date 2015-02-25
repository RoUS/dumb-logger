@inspect
Feature: Verify that our internals aren't improperly exposes.
  In order to use the basic functionality of the DumbLogger class
  A developer
  Should be able to manipulate all of the logger's attributes

  Background:
    Given I have a DumbLogger object

  Scenario: Check that #inspect doesn't include the @sink_io instance var
    When I query method inspect
    Then the return value should not include "@sink_io"
    And the return value should not include "@controls"
