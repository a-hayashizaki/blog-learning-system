require 'gemini-ai'

class ArticleGenerator
  def initialize(params)
    @original_memo = params[:original_memo]
    @theme = params[:theme]
    @experience_ratio = params[:experience_ratio].to_f
    @casualness_level = params[:casualness_level].to_i
    @structure_type = params[:structure_type]
    @client = setup_gemini_client
  end

  def generate
    validate_params
    
    if @client && Rails.application.config.gemini_api_key.present?
      generate_with_gemini_api
    else
      generate_sample_article
    end
  end

  private

  def setup_gemini_client
    api_key = Rails.application.config.gemini_api_key
    return nil unless api_key.present?
    
    Gemini.new(
      credentials: {
        service: 'generative-language-api',
        api_key: api_key
      },
      options: { model: 'gemini-pro', server_sent_events: true }
    )
  rescue => e
    Rails.logger.error "Gemini API setup failed: #{e.message}"
    nil
  end

  def validate_params
    raise "気づきメモが必要です" if @original_memo.blank?
    raise "テーマの選択が必要です" if @theme.blank?
    raise "体験記述比率は0.0-1.0の範囲で指定してください" unless (0.0..1.0).cover?(@experience_ratio)
    raise "カジュアルさレベルは1-5の範囲で指定してください" unless (1..5).cover?(@casualness_level)
  end

  def generate_with_gemini_api
    begin
      prompt = build_gemini_prompt
      
      result = @client.stream_generate_content({
        contents: { parts: { text: prompt } },
        generationConfig: {
          temperature: 0.7,
          maxOutputTokens: 2000,
        }
      })

      full_response = ""
      result.each do |fragment| 
        next unless fragment.dig('candidates', 0, 'content', 'parts')
        
        fragment.dig('candidates', 0, 'content', 'parts').each do |part|
          full_response += part['text'] if part['text']
        end
      end

      if full_response.present?
        parse_gemini_response(full_response)
      else
        Rails.logger.warn "Empty response from Gemini API"
        generate_sample_article
      end
    rescue => e
      Rails.logger.error "Gemini API error: #{e.message}"
      generate_sample_article
    end
  end

  def parse_gemini_response(response)
    lines = response.split("\n").map(&:strip).reject(&:empty?)
    
    title_index = lines.find_index { |line| line.match(/^(タイトル|title)/i) }
    content_index = lines.find_index { |line| line.match(/^(本文|内容|content)/i) }
    
    if title_index && content_index && title_index < content_index
      title = lines[title_index + 1] || "生成されたタイトル"
      content = lines[(content_index + 1)..-1]&.join("\n") || "生成された本文"
    else
      # フォールバック: 最初の行をタイトル、残りを本文とする
      title = lines.first || "生成されたタイトル"
      content = lines[1..-1]&.join("\n") || "生成された本文"
    end
    
    {
      title: title.gsub(/^(タイトル|title)[:：]\s*/i, ''),
      content: content.gsub(/^(本文|内容|content)[:：]\s*/i, '')
    }
  end

  def build_gemini_prompt
    theme_context = case @theme
    when 'coaching'
      'コーチングの視点から、読者の自己成長や目標達成を支援する内容'
    when 'self_compassion'
      'セルフコンパッション（自分への優しさ）の観点から、読者が自分を受け入れ、労われるような内容'
    end

    experience_guidance = if @experience_ratio > 0.7
      '個人的な体験や具体的なエピソードを豊富に織り交ぜた構成'
    elsif @experience_ratio > 0.3
      '理論と体験のバランスを取った構成'
    else
      '理論的な説明を中心に、適度に体験談を加えた構成'
    end

    tone_guidance = case @casualness_level
    when 1
      '丁寧で格式ある文体'
    when 2
      'やや丁寧な文体'
    when 3
      '親しみやすい文体'
    when 4
      'カジュアルで親しみやすい文体'
    when 5
      '非常にカジュアルで友達のような文体'
    end

    structure_guidance = case @structure_type
    when 'kishōtenketsu'
      '起承転結の構成（導入→展開→転換→結論）'
    when 'standard'
      '問題提起→解決策提示→具体例→まとめの標準的な構成'
    end

    <<~PROMPT
      以下の気づきメモをもとに、ブログ記事を生成してください。

      【気づきメモ】
      #{@original_memo}

      【生成条件】
      - #{theme_context}で記事を作成
      - #{experience_guidance}にする
      - #{tone_guidance}で執筆
      - #{structure_guidance}で構成

      【出力形式】
      タイトル: [ここにタイトル]

      本文:
      [ここに本文]

      読者が共感し、実践したくなるような内容で、800-1200文字程度のブログ記事を作成してください。
    PROMPT
  end

  def build_prompt
    theme_context = case @theme
    when 'coaching'
      'コーチングの視点から、読者の自己成長や目標達成を支援する内容で'
    when 'self_compassion'
      'セルフコンパッション（自分への優しさ）の観点から、読者が自分を受け入れ、労われるような内容で'
    end

    experience_guidance = if @experience_ratio > 0.7
      '個人的な体験や具体的なエピソードを豊富に織り交ぜて'
    elsif @experience_ratio > 0.3
      '理論と体験のバランスを取りながら'
    else
      '理論的な説明を中心に、適度に体験談を加えて'
    end

    tone_guidance = case @casualness_level
    when 1
      '丁寧で格式ある文体で'
    when 2
      'やや丁寧な文体で'
    when 3
      '親しみやすい文体で'
    when 4
      'カジュアルで親しみやすい文体で'
    when 5
      '非常にカジュアルで友達のような文体で'
    end

    structure_guidance = case @structure_type
    when 'kishōtenketsu'
      '起承転結の構成で、導入→展開→転換→結論の流れで'
    when 'standard'
      '問題提起→解決策提示→具体例→まとめの標準的な構成で'
    end

    <<~PROMPT
      以下の気づきメモをもとに、ブログ記事を生成してください。

      【気づきメモ】
      #{@original_memo}

      【生成条件】
      - #{theme_context}
      - #{experience_guidance}
      - #{tone_guidance}
      - #{structure_guidance}

      記事のタイトルと本文を生成してください。読者が共感し、実践したくなるような内容にしてください。
    PROMPT
  end

  def generate_sample_article
    # Phase1では簡単なテンプレートベースの生成を行う
    # 実際のAI統合は次のフェーズで実装
    
    theme_title = @theme == 'coaching' ? 'コーチング' : 'セルフコンパッション'
    casualness = %w[です である だ だよ だね][@casualness_level - 1] || 'です'
    
    title = "#{@original_memo.split('。').first&.strip}から学ぶ#{theme_title}の実践"
    
    content = build_article_content(casualness)
    
    {
      title: title,
      content: content
    }
  end

  def build_article_content(tone_suffix)
    sections = []
    
    # 導入部
    sections << "最近、こんなことを考えていました#{tone_suffix}。"
    sections << ""
    sections << @original_memo
    sections << ""
    
    # 展開部
    if @theme == 'coaching'
      sections << "この体験から、コーチングの視点で考えてみると、いくつかの重要なポイントが見えてきます#{tone_suffix}。"
    else
      sections << "この気づきをセルフコンパッションの観点から深めてみたいと思います#{tone_suffix}。"
    end
    sections << ""
    
    # 体験比率に応じた内容調整
    if @experience_ratio > 0.5
      sections << "具体的な体験を振り返ってみると..."
      sections << "私自身も同じような場面で..."
    else
      sections << "理論的に考えてみると..."
      sections << "研究によれば..."
    end
    sections << ""
    
    # 転換・まとめ部
    if @structure_type == 'kishōtenketsu'
      sections << "ところで、この考え方は日常の様々な場面で応用できるのではないでしょうか#{tone_suffix}。"
    else
      sections << "つまり、この気づきから得られる教訓は..."
    end
    sections << ""
    sections << "読者の皆さんも、同じような体験をされたことがあるかもしれません#{tone_suffix}。"
    sections << "少しでも参考になれば嬉しい#{tone_suffix}。"
    
    sections.join("\n")
  end
end