class CreateFeedbacks < ActiveRecord::Migration[8.0]
  def change
    create_table :feedbacks do |t|
      t.references :article, null: false, foreign_key: true
      t.integer :rating
      t.text :comment

      t.timestamps
    end
  end
end
