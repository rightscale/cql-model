Feature: Test with_keyspace()

  Background:
    Given a CQL model definition:
    """
      class Timeline
        include Cql::Model

        property :user_id,  Integer
        property :tweet_id, Integer
        property :text,     String

        primary_key :user_id, :tweet_id
      end
    """

  Scenario: with_keyspace should temporary set new keyspace
    When try: Timeline.with_keyspace('test_for_with_keyspace'){ Timeline.insert(:user_id => 42, :tweet_id => 13, :name => 'joe') }
    Then it should backup current keyspace, use 'test_for_with_keyspace' and restore previous one

  Scenario: should not restore old keyspace if old keyspace was not set
    When try: Timeline.with_keyspace('test_for_with_keyspace'){ Timeline.insert(:user_id => 42, :tweet_id => 13, :name => 'joe') }
    Then it should backup current keyspace, use 'test_for_with_keyspace' and do not restore previous one

  Scenario: with_keyspace should restore previous even if passed block raises an exception
    When try:
    """
      begin
        Timeline.with_keyspace('test_for_with_keyspace') do
          Timeline.insert(:user_id => 42, :tweet_id => 13, :name => 'joe')
          raise 'An exception'
        end
      rescue
      end
    """
    Then it should backup current keyspace, use 'test_for_with_keyspace' and restore previous one
