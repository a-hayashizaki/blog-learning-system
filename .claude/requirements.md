## ジョブ設計（Rails 8 Solid Queue）

### Rails 8 Background Jobs
```ruby
# app/jobs/application_job.rb
class ApplicationJob < ActiveJob::Base
  # Rails 8: Solid Queue as default adapter
  # Automatically includes retry functionality and error handling
  
  retry_on StandardError, wait: :exponentially_longer, attempts: 5
  discard_on ActiveJob::DeserializationError
  
  around_perform do |job, block|
    Rails.logger.info "Starting job: #{job.class.name}"
    block.call
    Rails.logger.info "Completed job: #{job.class.name}"
  end
end

# app/jobs/generate_article_job.rb
class GenerateArticleJob < ApplicationJob
  queue_as :default
  
  def perform(article)
    Rails.logger.info "Generating article for ID: #{article.id}"
    
    result = ArticleGenerationService.call(article)
    
    if result.success?
      # Rails 8: Turbo Streams for real-time updates
      broadcast_generation_complete(article, result.data[:content])
    else
      # Rails Way: Let retry mechanism handle failures
      raise StandardError, result.error
    end
  end
  
  private
  
  def broadcast_generation_complete(article, content)
    # Rails 8: Streamlined Turbo broadcasting
    Turbo::StreamsChannel.broadcast_replace_to(
      "article_#{article.id}",
      target: "article-content",
      partial: "articles/generated_content",
      locals: { article: article }
    )
  end
end

# app/jobs/note_api_sync_job.rb
class NoteApiSyncJob < ApplicationJob
  queue_as :low_priority
  
  # Rails 8: Cron-style job scheduling
  # config/schedule.rb: every 1.day, at: '2:00 AM' do; NoteApiSyncJob.perform_later; end
  
  def perform
    Article.needs_sync.find_each(batch_size: 10) do |article|
      result = NoteApiService.call(article)
      
      unless result.success?
        Rails.logger.warn "Failed to sync article #{article.id}: #{result.error}"
      end
      
      # API rate limiting
      sleep(2)
    end
  end
end

# app/jobs/learning_update_job.rb
class LearningUpdateJob < ApplicationJob
  queue_as :default
  
  def perform(article)
    # Rails Way: Update learning patterns after feedback
    LearningPatternUpdateService.call(article)
    
    # Trigger related article recommendations update
    RelatedArticlesUpdateService.call(article.theme)
  end
end
```

## ルーティング設計（Rails Way）

### Rails 8 RESTful Routes
```ruby
# config/routes.rb
Rails.application.routes.draw do
  # Rails 8: Improved routing DSL
  root "dashboard#index"
  
  # RESTful resources with Rails conventions
  resources :articles do
    # Nested resources
    resources :feedbacks, except: [:index, :show]
    
    # Member actions (operate on specific article)
    member do
      patch :publish
      post :regenerate
      get :preview
    end
    
    # Collection actions (operate on articles collection)
    collection do
      get :analytics
      get :export
    end
  end
  
  # Single resource for dashboard
  resource :dashboard, only: [:show] do
    get :insights
    get :trends
  end
  
  # Rails 8: Health check routes (built-in)
  # Automatically available at /up
  
  # Admin routes (future expansion)
  namespace :admin do
    resources :learning_patterns
    resources :system_settings
  end
end
```

## Rails 8新機能活用

### Authentication (Rails 8 built-in)
```ruby
# app/models/user.rb (future expansion)
class User < ApplicationRecord
  # Rails 8: Built-in authentication
  has_secure_password
  
  has_many :articles, dependent: :destroy
  
  validates :email, presence: true, uniqueness: true
end

# config/application.rb
class Application < Rails::Application
  # Rails 8: Built-in authentication configuration
  config.authentication.cookie_name = 'blog_learning_session'
end
```

### Solid Queue Configuration
```ruby
# config/queue.yml (Rails 8)
production:
  adapter: solid_queue
  database: storage/solid_queue.sqlite3
  workers:
    - queues: default,low_priority
      threads: 3
      processes: 2

development:
  adapter: solid_queue
  database: storage/solid_queue_development.sqlite3
  workers:
    - queues: default,low_priority
      threads: 1
      processes: 1
```

### Solid Cache (Rails 8)
```ruby
# config/environments/production.rb
config.cache_store = :solid_cache_store

# app/models/article.rb
class Article < ApplicationRecord
  # Rails 8: Enhanced caching
  after_update :clear_related_caches
  
  def self.learning_insights(theme: nil)
    cache_key = "learning_insights_#{theme || 'all'}"
    Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      # Expensive calculation
      calculate_learning_insights(theme)
    end
  end
  
  private
  
  def clear_related_caches
    Rails.cache.delete_matched("learning_insights_*")
    Rails.cache.delete("article_stats_summary")
  end
end
```

## 開発ロードマップ（Rails Way）

### Phase 1: Rails Way基盤
1. **Rails 8.0.2 アプリケーション作成**
   ```bash
   rails new blog_learning_system --css=tailwind --javascript=importmap
   ```
2. **基本モデル設計**
   - ActiveRecord migrations
   - Model validations & associations
   - Scopes & business logic methods
3. **RESTful Controllers**
   - Standard CRUD actions
   - Strong parameters
   - Before actions
4. **ERB Views + Tailwind**
   - Application layout
   - Shared partials
   - Form helpers

### Phase 2: ビジネスロジック実装
1. **Service Objects**
   - ArticleGenerationService
   - LearningService
   - NoteApiService
2. **Background Jobs (Solid Queue)**
   - Article generation jobs
   - Note API sync jobs
3. **AI Integration**
   - Google Gemini client
   - Error handling & retries

### Phase 3: 学習機能
1. **Learning Analytics**
   - Model concerns
   - Statistical calculations
   - Pattern recognition
2. **Real-time Updates**
   - Turbo Streams
   - Stimulus controllers
3. **Dashboard & Insights**
   - Data visualization
   - Trend analysis

### Phase 4: 最適化・拡張
1. **Performance**
   - Database indexing
   - Query optimization
   - Caching strategies
2. **Testing**
   - RSpec unit tests
   - Integration tests
   - Job testing
3. **Deployment Ready**
   - Production configuration
   - Monitoring & logging

## Rails 8移行後の追加機能

### Solid Queue Job Monitoring
```ruby
# app/controllers/admin/jobs_controller.rb
class Admin::JobsController < ApplicationController
  def index
    @jobs = SolidQueue::Job.includes(:execution)
                          .order(created_at: :desc)
                          .page(params[:page])
  end
  
  def show
    @job = SolidQueue::Job.find(params[:id])
  end
end
```

### Enhanced Error Handling
```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  # Rails 8: Improved error handling
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from StandardError, with: :internal_server_error
  
  private
  
  def record_not_found
    render file: Rails.root.join('public', '404.html'), 
           status: :not_found, 
           layout: false
  end
  
  def internal_server_error(exception)
    Rails.logger.error "Internal error: #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n")
    
    render file: Rails.root.join('public', '500.html'), 
           status: :internal_server_error, 
           layout: false
  end
end
```

この要件定義により、Rails 8.0.2の新機能を活用しながら、Rails Wayに完全準拠した保守性の高いアプリケーションが構築できます。# Blog Learning System - 要件定義書（Rails版）

## プロジェクト概要

### 目的
高頻度でブログを書きたいユーザーが、AI学習機能により記事品質を継続的に向上させるシステム。コーチングやセルフコンパッションの実体験を共有するブログに特化。

### 目標
- 週2-3回の記事投稿ペースを維持
- 繰り返し学習により記事品質を向上
- 自己評価と外部反応（note）の両方から学習
- 起承転結がしっかりした体験共有型記事の生成

## 核心機能

### 1. 記事生成ワークフロー
```
気づきメモ → AI対話で骨格作成 → 学習済み調整指示適用 → 記事完成
```

**現在の課題**: 毎回異なる調整指示（「体験をもっと多めに」「言葉を丁寧にしすぎない」等）を手動で出すため品質がブレる

**解決方法**: 過去の成功パターンを学習し、調整指示を自動生成

### 2. 学習システム（最重要機能）
**2段階での学習アプローチ**:
- **Phase 1**: プロンプト方式（シンプル、すぐ実装）
- **Phase 2**: ベクター埋め込み方式（高精度、将来実装）

**学習データ**:
- 自己フィードバック（5段階評価 + コメント）
- note外部反応（ビュー数、いいね数、コメント数・内容）
- 記事生成パラメータ（体験描写比率、語調、構成等）

### 3. note API連携
- 毎日自動でnote記事の反応データを取得
- 記事投稿は手動、データ取得は自動
- note認証設定済み

### 4. データ可視化・分析
- 過去記事の傾向分析（「最近の記事は体験描写が弱い傾向」等）
- 品質向上の推移グラフ
- テーマ別パフォーマンス分析

## 技術要件

### 技術スタック
- **フレームワーク**: Ruby on Rails 8.0.2
- **フロントエンド**: ERB + Tailwind CSS + Stimulus
- **データベース**: SQLite + ActiveRecord
- **デプロイ**: ローカル環境（個人利用）
- **AI API**: Google Gemini
- **外部API**: note API
- **ジョブキュー**: Solid Queue (Rails 8標準)

### 開発環境
- devcontainer + Claude Code
- Ruby 3.3+
- Rails 8.0.2
- **UIデザイン**: Notion風エディタ型（執筆に集中できるシンプル設計）
- **Rails Way準拠**: 慣習優先、設定最小化、DRY原則

### データ永続化
- 数年間のデータ保存
- 学習パターンの蓄積

## Rails Way 設計原則

### 慣習優先設定（Convention over Configuration）
- **RESTfulルーティング**: 標準的な7つのアクション中心
- **ディレクトリ構造**: Rails標準に準拠
- **命名規則**: ActiveRecordの慣習に従う
- **設定最小化**: rails newのデフォルト設定を最大活用

### DRY原則（Don't Repeat Yourself）
- **パーシャル活用**: 共通UIコンポーネントの再利用
- **ヘルパーメソッド**: ビューロジックの共通化
- **コンサーン**: モデル間の共通機能抽出
- **バリデーション**: 宣言的で簡潔な記述

### Fat Model, Skinny Controller
```ruby
# Good: モデルにビジネスロジック
class Article < ApplicationRecord
  def quality_score
    return nil unless self_rating && view_count && like_count
    (self_rating * 0.4) + (normalized_views * 0.3) + (normalized_likes * 0.3)
  end
  
  def high_quality?
    quality_score&.>= 4.0
  end
end

# Good: コントローラーはシンプル
class ArticlesController < ApplicationController
  def index
    @articles = Article.recent.high_quality
    @stats = @articles.stats_summary
  end
end
```

### ActiveRecord活用
- **スコープ**: 再利用可能なクエリ定義
- **関連**: belongs_to, has_many等の宣言的関連定義
- **コールバック**: ライフサイクルイベントの活用
- **バリデーション**: モデルレベルでのデータ整合性保証

## 学習ロジック詳細

### Rails Way学習機能設計
```ruby
# app/models/article.rb - Fat Model
class Article < ApplicationRecord
  # Rails 8 enum with instance methods
  enum :theme, { coaching: 0, self_compassion: 1, other: 2 }
  enum :structure_type, { basic: 0, story_driven: 1, problem_solution: 2 }
  
  # ActiveRecord validations
  validates :title, presence: true
  validates :content, presence: true
  validates :memo, presence: true
  validates :self_rating, inclusion: { in: 1..5 }, allow_nil: true
  
  # ActiveRecord associations
  has_many :feedbacks, dependent: :destroy
  has_many :note_comments, dependent: :destroy
  
  # ActiveRecord scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :high_rated, -> { where('self_rating >= ?', 4) }
  scope :published, -> { where.not(published_at: nil) }
  scope :by_theme, ->(theme) { where(theme: theme) }
  
  # ActiveRecord callbacks
  before_save :calculate_quality_score
  after_create :schedule_generation_job
  
  # Business logic in model
  def quality_score
    return nil unless self_rating && view_count && like_count
    (self_rating * 0.4) + (normalized_views * 0.3) + (normalized_likes * 0.3)
  end
  
  def high_quality?
    quality_score&.>= 4.0
  end
  
  def needs_improvement?
    !high_quality? && feedbacks.recent.any?
  end
  
  private
  
  def calculate_quality_score
    self.quality_score = quality_score if self_rating.present?
  end
  
  def schedule_generation_job
    GenerateArticleJob.perform_later(self) if content.blank?
  end
end

# app/models/concerns/learning_analytics.rb - Concern
module LearningAnalytics
  extend ActiveSupport::Concern
  
  class_methods do
    def learning_insights(theme: nil)
      scope = theme ? by_theme(theme) : all
      
      {
        avg_experience_ratio: scope.average(:experience_ratio),
        successful_patterns: scope.high_rated.group(:structure_type).count,
        improvement_areas: scope.where('self_rating < ?', 4).common_issues
      }
    end
    
    def stats_summary
      {
        total_count: count,
        avg_quality: average(:quality_score),
        high_quality_ratio: high_rated.count.to_f / count,
        recent_trend: recent.limit(10).average(:quality_score)
      }
    end
  end
end
```

### 学習要素
1. **体験描写比率**: 体験vs理論の最適バランス
2. **語調レベル**: 丁寧すぎない親しみやすさ
3. **構成パターン**: 起承転結の最適化
4. **テーマ別最適化**: コーチング vs セルフコンパッション
5. **エンゲージメント要因**: いいね・コメントを呼ぶ要素

### 評価軸
- **自己満足度**: 主観的品質（1-5段階）
- **リーチ力**: ビュー数
- **共感度**: いいね率
- **エンゲージメント**: コメント数・質

## データモデル（Rails Way ActiveRecord）

### Article モデル
```ruby
# app/models/article.rb
class Article < ApplicationRecord
  include LearningAnalytics
  
  # Rails 8 新機能: enum with instance methods
  enum :theme, { coaching: 0, self_compassion: 1, other: 2 }, 
       instance_methods: false
  enum :structure_type, { basic: 0, story_driven: 1, problem_solution: 2 }
  
  # ActiveRecord validations - 宣言的
  validates :title, presence: true, length: { maximum: 255 }
  validates :content, presence: true
  validates :memo, presence: true, length: { minimum: 10 }
  validates :self_rating, inclusion: { in: 1..5 }, allow_nil: true
  validates :experience_ratio, numericality: { 
    greater_than_or_equal_to: 0, 
    less_than_or_equal_to: 100 
  }, allow_nil: true
  
  # ActiveRecord associations
  has_many :feedbacks, dependent: :destroy
  has_many :note_comments, dependent: :destroy
  has_one_attached :featured_image # Rails Active Storage
  
  # ActiveRecord scopes - 再利用可能なクエリ
  scope :recent, -> { order(created_at: :desc) }
  scope :high_rated, -> { where(self_rating: 4..5) }
  scope :published, -> { where.not(published_at: nil) }
  scope :by_theme, ->(theme) { where(theme: theme) }
  scope :needs_sync, -> { where.not(note_id: nil).where('updated_at > last_synced_at OR last_synced_at IS NULL') }
  
  # ActiveRecord callbacks
  before_validation :set_defaults
  before_save :calculate_experience_ratio
  after_create :enqueue_generation
  after_update :update_learning_patterns, if: :saved_change_to_self_rating?
  
  # Business logic methods
  def quality_score
    return nil unless complete_feedback?
    weighted_score
  end
  
  def publishable?
    content.present? && title.present? && quality_score&.>= 3.0
  end
  
  def learning_data
    {
      experience_ratio: experience_ratio,
      casualness_level: casualness_level,
      structure_type: structure_type,
      engagement_metrics: {
        view_count: view_count,
        like_count: like_count,
        comment_count: comment_count
      }
    }
  end
  
  private
  
  def complete_feedback?
    self_rating.present? && view_count.present? && like_count.present?
  end
  
  def weighted_score
    # ビジネスロジック: 重み付けスコア計算
    (self_rating * 0.4) + 
    (normalized_engagement * 0.3) + 
    (content_quality_score * 0.3)
  end
  
  def set_defaults
    self.published_at ||= Time.current if content.present?
  end
  
  def enqueue_generation
    GenerateArticleJob.perform_later(self) if content.blank?
  end
end
```

### Feedback モデル
```ruby
# app/models/feedback.rb
class Feedback < ApplicationRecord
  belongs_to :article
  
  enum :feedback_type, { self: 0, note_api: 1, manual: 2 }
  
  validates :rating, inclusion: { in: 1..5 }, allow_nil: true
  validates :comment, presence: true, if: :rating_requires_comment?
  validates :feedback_type, presence: true
  
  scope :recent, -> { where(created_at: 1.week.ago..) }
  scope :positive, -> { where(rating: 4..5) }
  scope :negative, -> { where(rating: 1..2) }
  
  private
  
  def rating_requires_comment?
    rating.present? && rating <= 2
  end
end
```

### LearningPattern モデル
```ruby
# app/models/learning_pattern.rb
class LearningPattern < ApplicationRecord
  # Rails 8 serialize with class
  serialize :condition, coder: JSON
  serialize :action, coder: JSON
  serialize :metadata, coder: JSON
  
  validates :pattern_type, presence: true
  validates :condition, presence: true
  validates :action, presence: true
  validates :success_rate, numericality: { 
    greater_than_or_equal_to: 0.0,
    less_than_or_equal_to: 1.0 
  }
  
  scope :effective, -> { where('success_rate > ?', 0.7) }
  scope :by_type, ->(type) { where(pattern_type: type) }
  scope :recent_learnings, -> { where(created_at: 1.month.ago..) }
  
  def effective?
    success_rate > 0.7
  end
  
  def apply_to(article)
    # パターンを記事に適用するロジック
    case pattern_type
    when 'experience_ratio'
      article.experience_ratio = action['target_ratio']
    when 'casualness'
      article.casualness_level = action['target_level']
    end
  end
end
```

## UI/UXデザイン方針

### Notion風エディタ型デザイン
**選択理由**: 記事作成に最適化されたUX、執筆に集中できる環境

**Rails ERB実装**:
```erb
<!-- app/views/articles/new.html.erb -->
<div class="max-w-4xl mx-auto px-6 py-8">
  <!-- ヘッダー -->
  <header class="sticky top-0 z-10 bg-white/95 backdrop-blur-sm border-b border-gray-200 -mx-6 px-6 py-4 mb-8">
    <div class="flex items-center justify-between">
      <div class="flex items-center space-x-3">
        <div class="w-8 h-8 bg-gray-900 rounded-md flex items-center justify-center">
          <span class="text-white font-bold text-sm">BL</span>
        </div>
        <%= link_to "Blog Learning", root_path, class: "text-lg font-medium text-gray-900" %>
      </div>
      <div class="flex items-center space-x-4">
        <div class="flex items-center text-sm text-gray-500 bg-gray-100 px-3 py-1 rounded-full">
          <span class="w-2 h-2 bg-green-500 rounded-full mr-2"></span>
          AI学習済み
        </div>
        <%= form.submit "公開", class: "bg-blue-600 text-white px-4 py-2 rounded-md text-sm font-medium hover:bg-blue-700 transition-colors" %>
      </div>
    </div>
  </header>

  <%= form_with model: @article, local: true, class: "space-y-8" do |form| %>
    <!-- タイトル入力 -->
    <div>
      <%= form.text_field :title, 
          placeholder: "無題",
          class: "w-full text-4xl font-bold text-gray-900 placeholder-gray-400 border-none outline-none bg-transparent",
          data: { stimulus_target: "title" } %>
      <div class="flex items-center mt-4 space-x-4 text-sm text-gray-500">
        <div class="flex items-center">
          <span class="mr-1">📅</span>
          <span><%= Date.current.strftime("%Y年%m月%d日") %></span>
        </div>
        <div class="flex items-center">
          <span class="mr-1">🏷️</span>
          <%= form.select :theme, 
              options_for_select([
                ['コーチング', 'coaching'],
                ['セルフコンパッション', 'self_compassion'],
                ['その他', 'other']
              ]),
              {}, 
              { class: "bg-blue-100 text-blue-800 px-2 py-1 rounded-full text-xs border-none" } %>
        </div>
        <div class="flex items-center">
          <span class="mr-1">🎯</span>
          <span>推奨体験比率: <strong><%= @recommended_experience_ratio %>%</strong></span>
        </div>
      </div>
    </div>

    <!-- 気づきメモ -->
    <div class="bg-gray-50 rounded-lg p-6 border-l-4 border-amber-400">
      <div class="flex items-center mb-3">
        <span class="text-amber-600 mr-2 text-lg">💭</span>
        <h3 class="font-medium text-gray-900">気づきメモ</h3>
      </div>
      <%= form.text_area :memo,
          placeholder: "今日感じたこと、気づいたことを自由に書いてください...",
          rows: 4,
          class: "w-full bg-transparent border-none outline-none resize-none text-gray-700 placeholder-gray-500 focus:ring-0" %>
    </div>

    <!-- AI生成記事セクション -->
    <div id="generated-article" class="hidden">
      <div class="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6">
        <div class="flex items-center justify-between mb-2">
          <div class="flex items-center">
            <span class="text-blue-600 mr-2">🤖</span>
            <span class="font-medium text-blue-900">AI生成記事</span>
          </div>
          <div class="flex items-center space-x-2">
            <%= button_to "編集", "#", method: :post, remote: true, 
                class: "text-blue-600 hover:text-blue-800 text-sm underline" %>
            <%= button_to "再生成", "#", method: :post, remote: true,
                class: "text-blue-600 hover:text-blue-800 text-sm underline" %>
          </div>
        </div>
        <p class="text-sm text-blue-800">学習済みパターンに基づいて最適化されています</p>
      </div>

      <%= form.text_area :content,
          rows: 15,
          class: "w-full prose max-w-none border-none outline-none bg-transparent text-gray-800 leading-relaxed resize-none focus:ring-0" %>
    </div>

    <!-- 生成ボタン -->
    <div class="flex justify-center" id="generate-button">
      <%= form.submit "記事を生成", 
          class: "bg-blue-600 text-white px-8 py-3 rounded-lg font-medium hover:bg-blue-700 transition-colors",
          data: { 
            disable_with: "生成中...",
            stimulus_action: "click->article#generate"
          } %>
    </div>
  <% end %>
</div>

<!-- フローティング学習情報 -->
<div class="fixed bottom-6 right-6 bg-white rounded-lg shadow-lg border border-gray-200 p-4 w-72" 
     data-controller="stats-float">
  <div class="flex items-center justify-between mb-2">
    <h4 class="font-medium text-gray-900">学習状況</h4>
    <button class="text-gray-400 hover:text-gray-600" 
            data-action="click->stats-float#close">×</button>
  </div>
  <div class="space-y-2 text-sm">
    <div class="flex justify-between">
      <span class="text-gray-600">今月の記事数</span>
      <span class="font-medium"><%= @monthly_count %></span>
    </div>
    <div class="flex justify-between">
      <span class="text-gray-600">平均品質スコア</span>
      <span class="font-medium text-green-600"><%= @avg_quality_score %></span>
    </div>
    <div class="pt-2 border-t border-gray-100 text-xs text-gray-500">
      最近の改善: <%= @recent_improvement %>
    </div>
  </div>
</div>
```

## コントローラー設計（Rails Way）

### ApplicationController
```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  # Rails 8: CSRF protection is enabled by default
  
  before_action :set_current_user_context
  
  protected
  
  def set_current_user_context
    # 個人利用なので簡易実装、将来の拡張に備えて
    Current.user_id = 'default_user'
  end
end
```

### ArticlesController
```ruby
# app/controllers/articles_controller.rb
class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :edit, :update, :destroy, :publish]
  before_action :set_learning_context, only: [:new, :edit]

  # RESTful actions
  def index
    @articles = Article.includes(:feedbacks)
                      .recent
                      .page(params[:page])
    @stats = Article.stats_summary
  end

  def show
    @feedback = @article.feedbacks.build
    @related_articles = Article.by_theme(@article.theme)
                              .where.not(id: @article.id)
                              .high_rated
                              .limit(3)
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)
    
    if @article.save
      redirect_to @article, notice: t('.success')
    else
      set_learning_context
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # Rails Way: edit action should be simple
  end

  def update
    if @article.update(article_params)
      redirect_to @article, notice: t('.success')
    else
      set_learning_context
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @article.destroy!
    redirect_to articles_path, notice: t('.success')
  end

  # Custom actions (RESTful extension)
  def publish
    if @article.publishable?
      @article.update!(published_at: Time.current)
      redirect_to @article, notice: t('.published')
    else
      redirect_to @article, alert: t('.cannot_publish')
    end
  end

  private

  def article_params
    params.require(:article).permit(:title, :memo, :theme, :content, 
                                   :experience_ratio, :casualness_level, 
                                   :structure_type, :note_url)
  end

  def set_article
    @article = Article.find(params[:id])
  end

  def set_learning_context
    insights = Article.learning_insights(theme: params[:theme])
    @recommended_experience_ratio = insights[:avg_experience_ratio]&.round || 45
    @recent_improvements = LearningInsight.recent_for_theme(params[:theme])
  end
end
```

### FeedbacksController
```ruby
# app/controllers/feedbacks_controller.rb
class FeedbacksController < ApplicationController
  before_action :set_article
  before_action :set_feedback, only: [:show, :edit, :update, :destroy]

  def create
    @feedback = @article.feedbacks.build(feedback_params)
    @feedback.feedback_type = :self
    
    if @feedback.save
      # Rails Way: redirect after successful POST
      redirect_to @article, notice: t('.feedback_saved')
    else
      # Rails Way: render the parent view with errors
      @related_articles = Article.by_theme(@article.theme).limit(3)
      render 'articles/show', status: :unprocessable_entity
    end
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
```

### DashboardController
```ruby
# app/controllers/dashboard_controller.rb
class DashboardController < ApplicationController
  def index
    @stats = DashboardStats.new.call
    @recent_articles = Article.recent.limit(5)
    @learning_insights = LearningInsight.recent_insights
    @quality_trend = QualityTrendService.new.monthly_trend
  end
end
```

## サービスクラス設計（Rails Way）

### Rails Way Service Objects
```ruby
# app/services/application_service.rb
class ApplicationService
  # Rails Way: Base service class
  def self.call(...)
    new(...).call
  end

  def call
    raise NotImplementedError
  end
end

# app/services/article_generation_service.rb
class ArticleGenerationService < ApplicationService
  def initialize(article)
    @article = article
  end

  def call
    # Rails Way: サービスはビジネスロジックに集中
    optimized_prompt = LearningService.call(@article.theme)
    
    response = GeminiApiClient.new.generate_content(
      memo: @article.memo,
      theme: @article.theme.humanize,
      optimization_prompt: optimized_prompt
    )
    
    # Rails Way: モデルメソッドでデータ更新
    @article.update_with_generated_content(response.content)
    
    ServiceResult.success(content: response.content)
  rescue GeminiApiError => e
    Rails.logger.error "Article generation failed: #{e.message}"
    ServiceResult.failure(error: e.message)
  end
end

# app/services/learning_service.rb
class LearningService < ApplicationService
  def initialize(theme = nil)
    @theme = theme
  end

  def call
    insights = @theme ? Article.learning_insights(theme: @theme) : Article.learning_insights
    build_optimized_prompt(insights)
  end

  private

  def build_optimized_prompt(insights)
    <<~PROMPT
      学習済みパターンに基づく最適化指示：
      
      【体験描写】
      - 推奨比率: #{insights[:avg_experience_ratio]&.round || 45}%
      - 具体的なエピソードを2-3個含める
      
      【文体・構成】
      - 成功パターン: #{insights[:successful_patterns].keys.first || 'story_driven'}
      - 読者との共感を重視
      
      上記に基づいて自然で魅力的な記事を生成してください。
    PROMPT
  end
end

# app/services/note_api_service.rb
class NoteApiService < ApplicationService
  def initialize(article)
    @article = article
  end

  def call
    return ServiceResult.failure(error: "note_id not present") unless @article.note_id
    
    response = NoteApiClient.new.fetch_article_stats(@article.note_id)
    
    @article.update!(
      view_count: response['view_count'],
      like_count: response['like_count'],
      comment_count: response['comment_count'],
      last_synced_at: Time.current
    )
    
    ServiceResult.success(stats: response)
  rescue NoteApiError => e
    Rails.logger.error "Note API sync failed: #{e.message}"
    ServiceResult.failure(error: e.message)
  end
end

# app/services/service_result.rb
class ServiceResult
  attr_reader :success, :data, :error
  
  def initialize(success:, data: {}, error: nil)
    @success = success
    @data = data
    @error = error
  end
  
  def self.success(data = {})
    new(success: true, data: data)
  end
  
  def self.failure(error:, data: {})
    new(success: false, data: data, error: error)
  end
  
  def success?
    @success
  end
  
  def failure?
    !@success
  end
end
```

## ジョブ設計

### GenerateArticleJob
```ruby
# app/jobs/generate_article_job.rb
class GenerateArticleJob < ApplicationJob
  queue_as :default

  def perform(article)
    ArticleGenerationService.new(article).call
    
    # WebSocket経由でフロントエンドに通知
    ActionCable.server.broadcast(
      "article_#{article.id}",
      { 
        type: 'generation_complete',
        content: article.reload.content 
      }
    )
  end
end
```

### NoteApiSyncJob
```ruby
# app/jobs/note_api_sync_job.rb
class NoteApiSyncJob < ApplicationJob
  queue_as :default

  def perform
    Article.where.not(note_id: nil).find_each do |article|
      NoteApiService.new.sync_article_stats(article)
      sleep(1) # API制限対策
    end
  end
end
```

## 開発ロードマップ

### Phase 1: 基本機能（MVP）
1. Rails 7アプリケーション初期化
2. Article/Feedback/LearningPatternモデル作成
3. 基本的なCRUD画面（ERB + Tailwind）
4. Google Gemini API連携
5. 簡単な学習機能実装

### Phase 2: AI学習機能
1. LearningService実装
2. フィードバック収集・分析
3. プロンプト最適化ロジック
4. 学習効果の可視化

### Phase 3: note連携
1. note API実装
2. 外部反応データ取得・蓄積
3. 多重フィードバック学習
4. データ可視化ダッシュボード強化

### Phase 4: 高度化
1. バックグラウンドジョブ最適化
2. Stimulusによるインタラクション強化
3. 高度な分析機能
4. パフォーマンス最適化

## 成功指標

### 定量的指標
- 記事品質の継続的向上（自己評価平均の上昇）
- 外部反応の改善（ビュー数、いいね率の向上）
- 投稿頻度の維持（週2-3回）
- 学習精度の向上（予測的中率）

### 定性的指標
- ユーザーの執筆負担軽減
- 品質の安定化（ブレの減少）
- 読者との共感・エンゲージメント向上
- 継続的な改善実感

## 参考: 現在の手動調整パターン
ユーザーが現在AIに出している典型的な調整指示:
- "共感を重視するのでもっと体験を多めに記載して"
- "言葉を丁寧すぎない程度に"
- "会話形式のブログではなく私が記載したような形でアウトプットして"

これらの調整を学習により自動化することが本システムの核心価値。