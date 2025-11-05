class CreateSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :plan, null: false, foreign_key: true
      t.integer :status, default: 0, null: false
      t.datetime :started_at
      t.datetime :canceled_at

      t.timestamps
    end

    add_index :subscriptions, [:user_id, :status]
    add_index :subscriptions, :status
  end
end
