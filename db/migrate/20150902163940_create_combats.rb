class CreateCombats < ActiveRecord::Migration
  def change
    create_table :combats do |t|
      t.integer :pet1_id, index: true
      t.integer :pet2_id, index: true
      t.datetime :date
      t.integer :winner_id, index: true

      t.timestamps null: false
    end
  end
end
