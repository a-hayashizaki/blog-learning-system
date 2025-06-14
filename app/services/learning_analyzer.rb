class LearningAnalyzer
  def initialize
    @articles = Article.includes(:feedbacks)
  end

  def analyze_patterns
    return {} if @articles.empty?

    {
      theme_performance: analyze_theme_performance,
      experience_ratio_insights: analyze_experience_ratio,
      casualness_insights: analyze_casualness_level,
      structure_insights: analyze_structure_type,
      improvement_suggestions: generate_improvement_suggestions
    }
  end

  def generate_improved_prompt_parameters
    analysis = analyze_patterns

    # 最も成功しているパターンを基に推奨パラメータを生成
    best_params = find_best_performing_parameters

    {
      recommended_experience_ratio: best_params[:experience_ratio] || 0.6,
      recommended_casualness_level: best_params[:casualness_level] || 3,
      recommended_structure_type: best_params[:structure_type] || "standard",
      confidence_score: calculate_confidence_score(best_params),
      reasoning: generate_parameter_reasoning(best_params, analysis)
    }
  end

  private

  def analyze_theme_performance
    {
      coaching: {
        count: @articles.where(theme: "coaching").count,
        avg_rating: @articles.where(theme: "coaching").joins(:feedbacks).average("feedbacks.rating")&.round(2),
        feedback_count: @articles.where(theme: "coaching").joins(:feedbacks).count
      },
      self_compassion: {
        count: @articles.where(theme: "self_compassion").count,
        avg_rating: @articles.where(theme: "self_compassion").joins(:feedbacks).average("feedbacks.rating")&.round(2),
        feedback_count: @articles.where(theme: "self_compassion").joins(:feedbacks).count
      }
    }
  end

  def analyze_experience_ratio
    ratios = @articles.joins(:feedbacks).group("ROUND(experience_ratio, 1)")
                    .average("feedbacks.rating")

    best_ratio = ratios.max_by { |ratio, rating| rating }&.first

    {
      distribution: ratios,
      best_performing_ratio: best_ratio,
      recommendation: generate_ratio_recommendation(best_ratio)
    }
  end

  def analyze_casualness_level
    levels = @articles.joins(:feedbacks).group(:casualness_level)
                    .average("feedbacks.rating")

    best_level = levels.max_by { |level, rating| rating }&.first

    {
      distribution: levels,
      best_performing_level: best_level,
      recommendation: generate_casualness_recommendation(best_level)
    }
  end

  def analyze_structure_type
    structures = @articles.joins(:feedbacks).group(:structure_type)
                         .average("feedbacks.rating")

    {
      distribution: structures,
      recommendation: structures.max_by { |type, rating| rating }&.first
    }
  end

  def find_best_performing_parameters
    # 評価が4以上の記事のパラメータを分析
    high_rated_articles = @articles.joins(:feedbacks)
                                  .where("feedbacks.rating >= ?", 4)

    return {} if high_rated_articles.empty?

    {
      experience_ratio: high_rated_articles.average(:experience_ratio),
      casualness_level: high_rated_articles.mode(:casualness_level).first,
      structure_type: high_rated_articles.group(:structure_type).count.max_by(&:last)&.first
    }
  end

  def calculate_confidence_score(params)
    # データ量とパフォーマンスの一貫性に基づいて信頼度を計算
    total_articles = @articles.count
    high_rated_count = @articles.joins(:feedbacks).where("feedbacks.rating >= ?", 4).count

    return 0.1 if total_articles < 3
    return 0.3 if total_articles < 10
    return 0.5 if high_rated_count < 3

    consistency_score = high_rated_count.to_f / total_articles
    [ 0.9, 0.3 + consistency_score ].min
  end

  def generate_parameter_reasoning(params, analysis)
    reasoning = []

    if params[:experience_ratio]
      if params[:experience_ratio] > 0.7
        reasoning << "高い体験比率(#{(params[:experience_ratio] * 100).to_i}%)が読者の共感を得やすい傾向があります"
      elsif params[:experience_ratio] < 0.3
        reasoning << "理論重視のアプローチ(体験比率#{(params[:experience_ratio] * 100).to_i}%)が効果的です"
      else
        reasoning << "体験と理論のバランス(#{(params[:experience_ratio] * 100).to_i}%)が最適です"
      end
    end

    if params[:casualness_level]
      case params[:casualness_level]
      when 1..2
        reasoning << "丁寧で格式ある文体が読者に好まれています"
      when 3
        reasoning << "親しみやすい標準的な文体が効果的です"
      when 4..5
        reasoning << "カジュアルで親近感のある文体が成功しています"
      end
    end

    reasoning.join("。") + "。"
  end

  def generate_ratio_recommendation(best_ratio)
    return "データ不足のため、0.5-0.7の範囲で試してみてください" unless best_ratio

    case best_ratio
    when 0.0..0.3
      "理論的な説明を中心とした構成が効果的です"
    when 0.3..0.7
      "体験と理論のバランスが取れた構成が最適です"
    else
      "個人的な体験を豊富に含む構成が読者の共感を得ています"
    end
  end

  def generate_casualness_recommendation(best_level)
    return "カジュアル度3（標準的な親しみやすさ）から始めることをお勧めします" unless best_level

    case best_level
    when 1
      "フォーマルで丁寧な文体が最も効果的です"
    when 2
      "やや丁寧な文体が読者に好まれています"
    when 3
      "親しみやすい標準的な文体が最適です"
    when 4
      "カジュアルで親近感のある文体が成功しています"
    when 5
      "非常にカジュアルで友達のような文体が効果的です"
    end
  end

  def generate_improvement_suggestions
    suggestions = []

    # 記事数が少ない場合の提案
    if @articles.count < 10
      suggestions << "記事数を増やしてより正確な分析を行いましょう"
    end

    # フィードバックが少ない場合
    unfeedback_articles = @articles.left_joins(:feedbacks).where(feedbacks: { id: nil })
    if unfeedback_articles.any?
      suggestions << "#{unfeedback_articles.count}件の記事にフィードバックが未入力です"
    end

    # テーマのバランス
    theme_counts = @articles.group(:theme).count
    if theme_counts.values.any? { |count| count < 3 }
      suggestions << "両方のテーマ（コーチング・セルフコンパッション）でより多くの記事を書くことで、比較分析が可能になります"
    end

    suggestions
  end
end
