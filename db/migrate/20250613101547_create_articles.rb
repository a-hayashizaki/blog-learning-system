class CreateArticles < ActiveRecord::Migration[8.0]
  def change
    create_table :articles do |t|
      t.string :title
      t.text :content
      t.text :original_memo
      t.string :theme
      t.decimal :experience_ratio
      t.integer :casualness_level
      t.string :structure_type

      t.timestamps
    end
  end
end
