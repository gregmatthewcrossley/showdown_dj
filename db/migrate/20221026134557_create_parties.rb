class CreateParties < ActiveRecord::Migration[7.0]
  def change
    create_table :parties do |t|
      t.string :name
      t.string :playlist_uid
      t.integer :status, default: 0, null: false

      t.timestamps
    end
  end
end
