class CreateCanals < ActiveRecord::Migration[6.1]
  def change
    create_table :canals do |t|
      t.string :tipo
      t.string :descricao

      t.timestamps
    end
  end
end
