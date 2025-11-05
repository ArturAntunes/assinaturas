class CreatePlans < ActiveRecord::Migration[7.1]
  def change
    create_table :plans do |t|
      t.string :name, null: false
      t.integer :periodicity, default: 0, null: false
      t.integer :price_cents, null: false
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :plans, :active
  end
end
