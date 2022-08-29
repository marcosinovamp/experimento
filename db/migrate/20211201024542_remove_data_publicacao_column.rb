class RemoveDataPublicacaoColumn < ActiveRecord::Migration[6.1]
  def change
    remove_column :servicos, :data_publicacao
  end
end
