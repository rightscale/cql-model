Feature: DELETE statement

  Background:
    Given a CQL model definition:
    """
      class Timeline
        include Cql::Model

        property :user_id,  Integer
        property :tweet_id, Integer
        property :text,     String
        property :counter,  Integer

        primary_key :user_id, :tweet_id
      end
    """

  Scenario: simple update with partial primary key constraint
    When I call: delete
    Then it should generate CQL: DELETE FROM <model_class>

  Scenario: simple update with partial primary key constraint
    When I call: delete(:user_id)
    Then it should generate CQL: DELETE user_id FROM <model_class>

  Scenario: simple update with partial primary key constraint
    When I call: delete(:user_id, 'text')
    Then it should generate CQL: DELETE user_id, text FROM <model_class>

  Scenario: simple update with partial primary key constraint
    When I call: delete(:user_id, 'text', :tweet_id => [1,2,3])
    Then it should generate CQL: DELETE user_id, text, tweet_id[1, 2, 3] FROM <model_class>

  Scenario: simple update with partial primary key constraint
    When I call: delete(:user_id, 'text', :tweet_id => ['1','2','3'])
    Then it should generate CQL: DELETE user_id, text, tweet_id['1', '2', '3'] FROM <model_class>

  Scenario: simple update with partial primary key constraint
    When I call: delete(:user_id).timestamp(1366057256324)
    Then it should generate CQL: DELETE user_id FROM <model_class> USING TIMESTAMP 1366057256324 

  Scenario: simple update with partial primary key constraint
    When I call: delete(:user_id).timestamp(1366057256324).where{user_id == 11}
    Then it should generate CQL: DELETE user_id FROM <model_class> USING TIMESTAMP 1366057256324 WHERE user_id = 11

  Scenario: simple update with partial primary key constraint
    When I call: delete(:user_id).timestamp(1366057256324).where{user_id == 11}.consistency('ONE')
    Then it should generate CQL: DELETE user_id FROM <model_class> USING TIMESTAMP 1366057256324 WHERE user_id = 11

