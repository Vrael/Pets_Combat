class CreatePets < ActiveRecord::Migration
  def change
    create_table :pets do |t|
      t.string :name
      t.integer :age
      t.string :gender
      t.string :kind
      t.float :rate

      t.belongs_to :user, index: true

      t.timestamps null: false
    end
  end
end
