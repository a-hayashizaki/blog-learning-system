class Article < ApplicationRecord
  has_many :feedbacks, dependent: :destroy

  validates :title, presence: true
  validates :content, presence: true
  validates :original_memo, presence: true
  validates :theme, presence: true, inclusion: { in: %w[coaching self_compassion] }
  validates :experience_ratio, presence: true, inclusion: { in: 0.0..1.0 }
  validates :casualness_level, presence: true, inclusion: { in: 1..5 }
  validates :structure_type, presence: true, inclusion: { in: %w[kishōtenketsu standard] }

  enum :theme, { coaching: "coaching", self_compassion: "self_compassion" }
end
