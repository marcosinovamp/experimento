class AddDocQtdColumnToServico < ActiveRecord::Migration[6.1]
  def change
    add_column :servicos, :docqtd, :integer
  end
end
