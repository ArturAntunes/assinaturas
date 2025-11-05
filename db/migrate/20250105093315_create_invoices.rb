class CreateInvoices < ActiveRecord::Migration[7.1]
  def change
    create_table :invoices do |t|
      t.references :subscription, null: false, foreign_key: true
      t.date :reference_month, null: false
      t.integer :amount_cents, null: false
      t.date :due_on, null: false
      t.datetime :paid_at
      t.integer :status, default: 0, null: false

      t.timestamps
    end

    add_index :invoices, [:subscription_id, :reference_month]
    add_index :invoices, :status
    add_index :invoices, :due_on
  end
end
