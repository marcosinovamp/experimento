class CreateDocumentos < ActiveRecord::Migration[6.1]
  def change
    create_table :documentos do |t|
      t.string :nome
      t.integer "etapa_id", null: false
      t.index ["etapa_id"], name: "index_documentos_on_etapa_id"
      t.timestamps
    end
  end
end
