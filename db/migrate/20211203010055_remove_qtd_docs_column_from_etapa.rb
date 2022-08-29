class RemoveQtdDocsColumnFromEtapa < ActiveRecord::Migration[6.1]
  def change
    remove_column :etapas, :qtd_docs
  end
end
