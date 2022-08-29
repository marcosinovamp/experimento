class AddEtapaToTaxa < ActiveRecord::Migration[6.1]
  def change
    add_reference :taxas, :etapa, null: false, foreign_key: true
  end
end
