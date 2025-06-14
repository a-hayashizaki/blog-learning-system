class FeedbacksController < ApplicationController
  before_action :set_article
  before_action :set_feedback, only: [ :edit, :update, :destroy ]

  def create
    @feedback = @article.feedbacks.build(feedback_params)

    if @feedback.save
      redirect_to @article, notice: "フィードバックが送信されました。"
    else
      redirect_to @article, alert: "フィードバックの送信に失敗しました。"
    end
  end

  def edit
  end

  def update
    if @feedback.update(feedback_params)
      redirect_to @article, notice: "フィードバックが更新されました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @feedback.destroy
    redirect_to @article, notice: "フィードバックが削除されました。"
  end

  private

  def set_article
    @article = Article.find(params[:article_id])
  end

  def set_feedback
    @feedback = @article.feedbacks.find(params[:id])
  end

  def feedback_params
    params.require(:feedback).permit(:rating, :comment)
  end
end
