class AddQtdDocColumnToEtapa < ActiveRecord::Migration[6.1]
  def change
    add_column :etapas, :qtd_docs, :integer
  end
end
