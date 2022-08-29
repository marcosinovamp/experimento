class RemoveColumnsCanaisCustosFromEtapa < ActiveRecord::Migration[6.1]
  def change
    remove_column :etapas, :canais
    remove_column :etapas, :custos
  end
end
