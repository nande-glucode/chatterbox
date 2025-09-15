class CreateContacts < ActiveRecord::Migration[8.0]
  def change
    create_table :contacts do |t|
      t.references :requester, null: false, foreign_key: { to_table: :users }
      t.references :requested, null: false, foreign_key: { to_table: :users }
      t.string :status, null: false, default: 'pending'

      t.timestamps
    end

    add_index :contacts, [:requester_id, :requested_id], unique: true
  end
end
