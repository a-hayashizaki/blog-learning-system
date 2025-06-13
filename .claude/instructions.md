# Claude Code 開発指示 - Rails 8.0.2版

## システム概要
ブログ記事の品質を学習により継続的に向上させるRails 8.0.2アプリケーション。コーチング・セルフコンパッション分野の体験共有ブログに特化。Rails Way完全準拠、ERB + Tailwind CSS + Stimulusでの実装。

## 開発タスク優先順位

### 1. Rails 8.0.2基盤構築（最優先）
- [ ] Rails 8.0.2アプリケーション初期化
  ```bash
  rails new blog_learning_system --css=tailwind --javascript=importmap
  cd blog_learning_system
  ```
- [ ] Gemfile設定（Solid Queue, google-generative-ai, httparty等）
- [ ] Rails 8設定ファイル調整（Solid Queue, Solid Cache）
- [ ] データベース設計・マイグレーション作成
- [ ] RESTfulルーティング設定
- [ ] 環境変数設定（.env, credentials）

### 2. Rails Way ActiveRecordモデル実装
- [ ] **Article モデル**（主要ビジネスロジック）
  ```ruby
  # Rails 8 enum with instance methods
  enum :theme, { coaching: 0, self_compassion: 1, other: 2 }
  
  # Fat Model - ビジネスロジックをモデルに集約
  def quality_score
    return nil unless complete_feedback?
    (self_rating * 0.4) + (normalized_engagement * 0.3) + (content_quality_score * 0.3)
  end
  
  # ActiveRecord scopes
  scope :high_rated, -> { where(self_rating: 4..5) }
  scope :recent, -> { order(created_at: :desc) }
  ```
- [ ] **Feedback モデル**（評価データ）
- [ ] **LearningPattern モデル**（学習パターン蓄積）
- [ ] **LearningAnalytics Concern**（共通学習機能）
- [ ] モデル間関連設定、バリデーション、コールバック

### 3. Rails Way RESTfulコントローラー
- [ ] **ApplicationController**（共通処理）
- [ ] **ArticlesController**（標準CRUD + publish, regenerate）
  ```ruby
  # Skinny Controller - ロジックはモデル・サービスに委譲
  def create
    @article = Article.new(article_params)
    
    if @article.save
      redirect_to @article, notice: t('.success')
    else
      set_learning_context
      render :new, status: :unprocessable_entity
    end
  end
  ```
- [ ] **FeedbacksController**（ネストしたリソース）
- [ ] **DashboardController**（統計・分析）
- [ ] Strong Parameters, Before Actions設定

### 4. Service Objects（Rails Way責務分離）
- [ ] **ApplicationService**（基底サービスクラス）
- [ ] **ArticleGenerationService**（AI記事生成）
- [ ] **LearningService**（学習ロジック）
- [ ] **NoteApiService**（外部API連携）
- [ ] **ServiceResult**（統一されたレスポンス形式）

### 5. Rails 8 Solid Queue ジョブ
- [ ] **ApplicationJob**（基底ジョブクラス）
- [ ] **GenerateArticleJob**（記事生成の非同期処理）
- [ ] **NoteApiSyncJob**（定期的なnote API同期）
- [ ] **LearningUpdateJob**（学習パターン更新）
- [ ] Solid Queue設定（config/queue.yml）

### 6. Notion風UI実装（ERB + Tailwind）
- [ ] **Application Layout**（共通レイアウト）
  ```erb
  <!-- app/views/layouts/application.html.erb -->
  <!DOCTYPE html>
  <html class="h-full bg-white">
    <head>
      <title>Blog Learning System</title>
      <%= csrf_meta_tags %>
      <%= csp_meta_tag %>
      <%= stylesheet_link_tag "tailwind", "data-turbo-track": "reload" %>
      <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
      <%= javascript_importmap_tags %>
    </head>
    <body class="h-full">
      <%= yield %>
    </body>
  </html>
  ```
- [ ] **記事作成フォーム**（new.html.erb）
- [ ] **記事詳細ページ**（show.html.erb）
- [ ] **ダッシュボード**（dashboard/index.html.erb）
- [ ] **共通パーシャル**（ヘッダー、フィードバックフォーム等）

### 7. Stimulus JavaScript Controllers
- [ ] **article_controller.js**（記事生成、リアルタイム更新）
- [ ] **feedback_controller.js**（評価投稿）
- [ ] **stats_float_controller.js**（フローティング統計）

### 8. Rails 8新機能統合
- [ ] **Solid Cache**（学習データキャッシング）
- [ ] **Turbo Streams**（リアルタイム更新）
- [ ] **Error Handling**（Rails 8改善機能活用）

## 重要な実装ポイント

### Rails Way設計原則の厳守

#### 1. Convention over Configuration
```ruby
# Good: Rails慣習に従う
class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :edit, :update, :destroy, :publish]
  
  def index
    @articles = Article.includes(:feedbacks).recent.page(params[:page])
  end
end

# ルーティング: RESTful
resources :articles do
  resources :feedbacks, except: [:index, :show]
  member { patch :publish }
end
```

#### 2. Fat Model, Skinny Controller
```ruby
# app/models/article.rb - ビジネスロジックはモデルに
class Article < ApplicationRecord
  include LearningAnalytics
  
  # ActiveRecord features
  enum :theme, { coaching: 0, self_compassion: 1, other: 2 }
  validates :title, presence: true, length: { maximum: 255 }
  scope :publishable, -> { where.not(content: nil) }
  
  # Business logic
  def publishable?
    content.present? && title.present? && quality_score&.>= 3.0
  end
  
  def update_with_generated_content(content)
    update!(
      content: content,
      experience_ratio: extract_experience_ratio(content),
      casualness_level: calculate_casualness_level(content)
    )
  end
  
  private
  
  def extract_experience_ratio(content)
    # ビジネスロジック実装
  end
end

# app/controllers/articles_controller.rb - コントローラーはシンプル
class ArticlesController < ApplicationController
  def publish
    if @article.publishable?
      @article.update!(published_at: Time.current)
      redirect_to @article, notice: t('.published')
    else
      redirect_to @article, alert: t('.cannot_publish')
    end
  end
end
```

#### 3. Service Objects
```ruby
# app/services/application_service.rb
class ApplicationService
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
    optimized_prompt = LearningService.call(@article.theme)
    
    response = GeminiApiClient.new.generate_content(
      memo: @article.memo,
      theme: @article.theme.humanize,
      optimization_prompt: optimized_prompt
    )
    
    @article.update_with_generated_content(response.content)
    ServiceResult.success(content: response.content)
  rescue GeminiApiError => e
    Rails.logger.error "Article generation failed: #{e.message}"
    ServiceResult.failure(error: e.message)
  end
end
```

### Rails 8特有の実装

#### Solid Queue Jobs
```ruby
# app/jobs/generate_article_job.rb
class GenerateArticleJob < ApplicationJob
  queue_as :default
  
  def perform(article)
    result = ArticleGenerationService.call(article)
    
    if result.success?
      # Rails 8: Turbo Streams broadcasting
      broadcast_generation_complete(article)
    else
      raise StandardError, result.error
    end
  end
  
  private
  
  def broadcast_generation_complete(article)
    Turbo::StreamsChannel.broadcast_replace_to(
      "article_#{article.id}",
      target: "article-content",
      partial: "articles/generated_content",
      locals: { article: article }
    )
  end
end
```

#### Solid Cache活用
```ruby
# app/models/article.rb
class Article < ApplicationRecord
  def self.learning_insights(theme: nil)
    cache_key = "learning_insights_#{theme || 'all'}"
    Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      calculate_learning_insights(theme)
    end
  end
  
  after_update :clear_related_caches
  
  private
  
  def clear_related_caches
    Rails.cache.delete_matched("learning_insights_*")
  end
end
```

### Notion風UI実装（ERB + Tailwind）

#### 記事作成フォーム
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
      </div>
    </div>
  </header>

  <%= form_with model: @article, local: true, 
      class: "space-y-8",
      data: { controller: "article", turbo_frame: "article-form" } do |form| %>
    
    <!-- タイトル入力 -->
    <div>
      <%= form.text_field :title, 
          placeholder: "無題",
          class: "w-full text-4xl font-bold text-gray-900 placeholder-gray-400 border-none outline-none bg-transparent",
          data: { article_target: "title" } %>
      
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
          class: "w-full bg-transparent border-none outline-none resize-none text-gray-700 placeholder-gray-500 focus:ring-0",
          data: { article_target: "memo" } %>
    </div>

    <!-- AI生成セクション -->
    <turbo-frame id="generated-article">
      <div class="flex justify-center">
        <%= form.submit "記事を生成", 
            class: "bg-blue-600 text-white px-8 py-3 rounded-lg font-medium hover:bg-blue-700 transition-colors",
            data: { 
              disable_with: "生成中...",
              action: "click->article#generate"
            } %>
      </div>
    </turbo-frame>
  <% end %>
</div>
```

#### Stimulus Controller
```javascript
// app/javascript/controllers/article_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["title", "memo", "content"]
  
  connect() {
    console.log("Article controller connected")
  }
  
  async generate(event) {
    event.preventDefault()
    
    const formData = new FormData(this.element)
    
    try {
      const response = await fetch('/articles', {
        method: 'POST',
        body: formData,
        headers: {
          'X-Requested-With': 'XMLHttpRequest'
        }
      })
      
      if (!response.ok) {
        throw new Error('Generation failed')
      }
      
      // Turbo will handle the response automatically
      
    } catch (error) {
      console.error('Article generation error:', error)
      this.showError('記事生成に失敗しました。もう一度お試しください。')
    }
  }
  
  showError(message) {
    // Simple error display - can be enhanced
    alert(message)
  }
}
```

### マイグレーション例
```ruby
# db/migrate/001_create_articles.rb
class CreateArticles < ActiveRecord::Migration[8.0]
  def change
    create_table :articles do |t|
      # 基本情報
      t.string :title, null: false
      t.text :content
      t.text :memo, null: false
      t.integer :theme, default: 0, null: false
      t.string :note_url
      t.string :note_id

      # 生成パラメータ
      t.integer :experience_ratio
      t.integer :casualness_level
      t.integer :structure_type, default: 0

      # 自己評価
      t.integer :self_rating
      t.text :self_comment

      # 外部反応データ
      t.integer :view_count
      t.integer :like_count
      t.integer :comment_count

      # 学習用データ
      t.text :learning_tags
      t.float :quality_score

      t.timestamps
      t.datetime :published_at
      t.datetime :last_synced_at
    end

    # Rails 8: Enhanced indexing
    add_index :articles, :theme
    add_index :articles, :created_at
    add_index :articles, :self_rating
    add_index :articles, :quality_score
    add_index :articles, :published_at
    add_index :articles, [:theme, :self_rating]
  end
end
```

## 設定ファイル例

### Rails 8 Solid Queue設定
```yaml
# config/queue.yml
default: &default
  adapter: solid_queue
  
development:
  <<: *default
  database: storage/solid_queue_development.sqlite3
  workers:
    - queues: default,low_priority
      threads: 1
      processes: 1

production:
  <<: *default
  database: storage/solid_queue.sqlite3
  workers:
    - queues: default
      threads: 3
      processes: 2
    - queues: low_priority
      threads: 1
      processes: 1
```

### 環境設定
```ruby
# config/environments/development.rb
Rails.application.configure do
  # Rails 8 defaults
  config.enable_reloading = true
  config.eager_load = false
  
  # Solid Queue
  config.active_job.queue_adapter = :solid_queue
  
  # Solid Cache
  config.cache_store = :solid_cache_store
  
  # Tailwind in development
  config.tailwindcss.builds = {
    "application.css" => "app/assets/stylesheets/application.tailwind.css"
  }
end
```

## テスト戦略

### RSpec設定
```ruby
# spec/rails_helper.rb
require 'spec_helper'

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  
  # Rails 8: Job testing
  config.include ActiveJob::TestHelper
end

# spec/models/article_spec.rb
RSpec.describe Article, type: :model do
  describe 'validations' do
    it 'requires title and memo' do
      article = Article.new
      expect(article).not_to be_valid
      expect(article.errors[:title]).to include("can't be blank")
      expect(article.errors[:memo]).to include("can't be blank")
    end
  end
  
  describe '#quality_score' do
    it 'calculates weighted score correctly' do
      article = create(:article, self_rating: 4, view_count: 100, like_count: 10)
      expect(article.quality_score).to be_present
    end
  end
end

# spec/services/article_generation_service_spec.rb
RSpec.describe ArticleGenerationService do
  describe '#call' do
    let(:article) { create(:article, :with_memo) }
    
    it 'generates content successfully' do
      result = described_class.call(article)
      expect(result).to be_success
      expect(article.reload.content).to be_present
    end
  end
end
```

## デプロイ・運用

### 本番環境設定
```ruby
# config/environments/production.rb
Rails.application.configure do
  config.eager_load = true
  config.cache_store = :solid_cache_store
  config.active_job.queue_adapter = :solid_queue
  
  # Logging
  config.log_level = :info
  config.log_tags = [:request_id]
end
```

### モニタリング
```ruby
# app/controllers/admin/system_controller.rb
class Admin::SystemController < ApplicationController
  def health
    render json: {
      status: 'ok',
      database: database_status,
      cache: cache_status,
      jobs: job_queue_status
    }
  end
  
  private
  
  def database_status
    Article.connection.active? ? 'connected' : 'disconnected'
  rescue
    'error'
  end
  
  def cache_status
    Rails.cache.write('health_check', Time.current)
    Rails.cache.read('health_check') ? 'working' : 'error'
  rescue
    'error'
  end
  
  def job_queue_status
    SolidQueue::Job.count
  rescue
    'error'
  end
end
```

## 開発フロー

### 1. 初期セットアップ
```bash
# Rails 8.0.2 アプリケーション作成
rails new blog_learning_system --css=tailwind --javascript=importmap
cd blog_learning_system

# Gemfile編集後
bundle install

# データベース設定
rails db:create
rails generate model Article title:string content:text memo:text theme:integer
rails db:migrate

# 初期ルーティング
rails generate controller Articles index new show
```

### 2. Rails Way実装順序
1. **モデル設計**（ビジネスロジック、バリデーション、関連）
2. **マイグレーション**（適切なインデックス含む）
3. **コントローラー**（RESTful、シンプル）
4. **ビュー**（ERB + Tailwind、パーシャル活用）
5. **サービス**（複雑なビジネスロジック分離）
6. **ジョブ**（非同期処理）
7. **Stimulus**（インタラクション）

### 3. テスト駆動開発
```bash
# モデルテスト
rails generate rspec:model Article
bundle exec rspec spec/models/

# サービステスト  
mkdir spec/services
bundle exec rspec spec/services/

# コントローラーテスト
bundle exec rspec spec/controllers/
```

## 期待する成果物

### Phase 1完了時（Rails Way基盤）
- Rails 8.0.2での完全なCRUDアプリケーション
- ActiveRecord中心のデータ設計
- RESTfulなルーティング・コントローラー
- 基本的なNotion風UI（ERB + Tailwind）
- Google Gemini API連携

### Phase 2完了時（学習機能）
- Service Objectsでの学習ロジック実装
- Solid Queueでのバックグラウンド処理
- フィードバック収集・分析機能
- Solid Cacheでの最適化

### Phase 3完了時（完全版）
- note API完全連携
- Turbo Streamsでのリアルタイム更新
- Stimulusでの高度なインタラクション
- 包括的な学習・分析ダッシュボード

この指示に従って、Rails 8.0.2の新機能を活用しながら、Rails Wayに完全準拠した保守性・拡張性の高いアプリケーションを構築してください。