class RemoveDuracaoColumnEtapa < ActiveRecord::Migration[6.1]
  def change
    remove_column :etapas, :duracao
  end
end
