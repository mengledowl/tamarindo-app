class CreateVariants < ActiveRecord::Migration[5.1]
  def change
    create_table :variants do |t|
      t.integer :shopify_variant_id
      t.text :logon_style
      t.text :logon_col
      t.text :logon_dm
      t.text :logon_size

      t.timestamps
    end
  end
end
