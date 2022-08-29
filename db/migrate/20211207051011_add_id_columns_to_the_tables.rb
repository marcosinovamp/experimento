class AddIdColumnsToTheTables < ActiveRecord::Migration[6.1]
  def change
    add_column :orgaos, :api_id, :integer
    add_column :etapas, :api_id, :integer
    add_column :canals, :api_id, :integer
    add_column :documentos, :api_id, :integer
    add_column :taxas, :api_id, :integer
  end
end
