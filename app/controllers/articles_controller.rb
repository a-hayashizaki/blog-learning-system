class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :edit, :update, :destroy]

  def index
    @articles = Article.all.order(created_at: :desc)
    @learning_analysis = LearningAnalyzer.new.analyze_patterns if @articles.any?
  end

  def show
    @feedback = @article.feedbacks.build
  end

  def new
    @article = Article.new
    
    # 学習済み推奨パラメータを取得
    if Article.joins(:feedbacks).exists?
      analyzer = LearningAnalyzer.new
      recommendations = analyzer.generate_improved_prompt_parameters
      
      @article.experience_ratio = recommendations[:recommended_experience_ratio]
      @article.casualness_level = recommendations[:recommended_casualness_level]
      @article.structure_type = recommendations[:recommended_structure_type]
      @recommendations = recommendations
    else
      # デフォルト値
      @article.experience_ratio = 0.5
      @article.casualness_level = 3
      @article.structure_type = 'standard'
    end
  end

  def create
    @article = Article.new(article_params)
    
    if @article.save
      redirect_to @article, notice: '記事が作成されました。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @article.update(article_params)
      redirect_to @article, notice: '記事が更新されました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @article.destroy
    redirect_to articles_path, notice: '記事が削除されました。'
  end

  def generate
    begin
      generator = ArticleGenerator.new(generate_params)
      result = generator.generate
      
      render json: {
        title: result[:title],
        content: result[:content]
      }
    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  private

  def set_article
    @article = Article.find(params[:id])
  end

  def article_params
    params.require(:article).permit(:title, :content, :original_memo, :theme, :experience_ratio, :casualness_level, :structure_type)
  end

  def generate_params
    params.permit(:original_memo, :theme, :experience_ratio, :casualness_level, :structure_type)
  end
end
