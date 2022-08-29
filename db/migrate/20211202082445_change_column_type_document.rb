class ChangeColumnTypeDocument < ActiveRecord::Migration[6.1]
  def change
    change_column :documentos, :nome, :text
  end
end
