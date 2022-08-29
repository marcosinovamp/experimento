class AddNomeApiColumnToServico < ActiveRecord::Migration[6.1]
  def change
    add_column :servicos, :nome_api, :string
  end
end
