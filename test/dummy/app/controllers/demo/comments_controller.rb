# frozen_string_literal: true

module Demo
  class CommentsController < ApplicationController
    def create
      comment = DemoComment.new(comment_attributes)

      if comment.save
        redirect_to demo_comments_path(anchor: "comment-#{comment.id}"), notice: "Comment posted."
      else
        redirect_to demo_comments_path, alert: comment.errors.full_messages.to_sentence
      end
    end

    def replies
      parent_comment = DemoComment.find(params[:id])
      reply = parent_comment.replies.build(comment_attributes)

      if reply.save
        redirect_to demo_comments_path(anchor: "comment-#{reply.id}"), notice: "Reply posted."
      else
        redirect_to demo_comments_path(reply_to: parent_comment.id, anchor: "comment-#{parent_comment.id}"), alert: reply.errors.full_messages.to_sentence
      end
    end

    private

    def comment_attributes
      params.require(:comment).permit(:body).to_h.merge(author_name: "You")
    end
  end
end
