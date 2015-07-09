class CreateMonths < ActiveRecord::Migration
  def change
    create_table :months do |t|
      t.string :name
      t.integer :year
      t.integer :num

      t.timestamps null: false
    end
  end
end
