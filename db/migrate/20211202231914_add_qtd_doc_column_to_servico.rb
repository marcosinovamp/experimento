class AddQtdDocColumnToServico < ActiveRecord::Migration[6.1]
  def change
    add_column :servicos, :qtd_docs, :integer
  end
end
