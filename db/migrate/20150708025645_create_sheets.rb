class CreateSheets < ActiveRecord::Migration
  def change
    create_table :sheets do |t|
      t.integer :day
      t.integer :in_time
      t.integer :out_time
      t.integer :lunch_start
      t.integer :lunch_end
      t.references :month, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
