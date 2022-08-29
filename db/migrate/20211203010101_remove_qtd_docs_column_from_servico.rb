class RemoveQtdDocsColumnFromServico < ActiveRecord::Migration[6.1]
  def change
    remove_column :servicos, :qtd_docs
  end
end
