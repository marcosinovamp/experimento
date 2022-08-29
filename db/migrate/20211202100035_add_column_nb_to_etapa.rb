class AddColumnNbToEtapa < ActiveRecord::Migration[6.1]
  def change
    add_column :etapas, :nb, :integer
  end
end
