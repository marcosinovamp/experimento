class AddEtapaToCanal < ActiveRecord::Migration[6.1]
  def change
    add_reference :canals, :etapa, null: false, foreign_key: true
  end
end
