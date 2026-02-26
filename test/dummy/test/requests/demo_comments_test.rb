# frozen_string_literal: true

require "test_helper"

class DemoCommentsTest < ActionDispatch::IntegrationTest
  setup do
    @parent_comment = DemoComment.create!(
      author_name: "Alice",
      body: "Parent comment"
    )
  end

  test "creates a top-level comment" do
    assert_difference("DemoComment.count", 1) do
      post demo_comments_path, params: {
        comment: {
          body: "Hello from request test"
        }
      }
    end

    assert_response :redirect

    created = DemoComment.order(:id).last
    assert_equal "Hello from request test", created.body
    assert_equal "You", created.author_name
    assert_nil created.parent_comment_id
  end

  test "creates a reply for an existing comment" do
    assert_difference("DemoComment.count", 1) do
      post replies_demo_comment_path(@parent_comment), params: {
        comment: {
          body: "This is a nested reply"
        }
      }
    end

    assert_response :redirect

    reply = DemoComment.order(:id).last
    assert_equal @parent_comment.id, reply.parent_comment_id
    assert_equal "This is a nested reply", reply.body
    assert_equal "You", reply.author_name
  end

  test "returns to demo with alert when body is blank" do
    assert_no_difference("DemoComment.count") do
      post demo_comments_path, params: {
        comment: {
          body: "   "
        }
      }
    end

    assert_response :redirect
    follow_redirect!
    assert_match(/Body can/i, response.body)
    assert_match(/blank/i, response.body)
  end
end
