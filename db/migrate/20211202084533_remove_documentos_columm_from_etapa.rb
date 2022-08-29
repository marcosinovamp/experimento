class RemoveDocumentosColummFromEtapa < ActiveRecord::Migration[6.1]
  def change
    remove_column :etapas, :documentos
  end
end
