class CreateEtapas < ActiveRecord::Migration[6.1]
  def change
    create_table :etapas do |t|
      t.string :nome
      t.string :descricao
      t.string :duracao
      t.string :documentos
      t.string :canais
      t.string :custos
      t.boolean :digital

      t.timestamps
    end
  end
end
