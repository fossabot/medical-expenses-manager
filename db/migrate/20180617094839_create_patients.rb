class CreatePatients < ActiveRecord::Migration[5.2]
  def change
    create_table :patients do |t|
      t.string :name, null: false, unique: true
      t.string :relationship
      t.timestamps
    end
  end
end
