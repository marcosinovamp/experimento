class AddColumnsToEtapa < ActiveRecord::Migration[6.1]
  def change
    add_column :etapas, :nome_etapa_portal, :string
    add_column :etapas, :descricao_etapa_portal, :string
  end
end
