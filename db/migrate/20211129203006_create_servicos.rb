class CreateServicos < ActiveRecord::Migration[6.1]
  def change
    create_table :servicos do |t|
      t.string :nome
      t.string :url
      t.integer :api_id
      t.string :categoria_nivel1
      t.string :categoria_nivel2
      t.string :categoria_nivel3
      t.date :data_publicacao
      t.date :data_modificacao
      t.string :orgao
      t.string :nomes_populares
      t.boolean :botao_solicitar
      t.string :link_botaosolicitar
      t.boolean :gratuito
      t.string :descricao
      t.integer :avaliacoes_positivas
      t.integer :avaliacoes_negativas
      t.string :segmentos
      t.string :palavras_chave
      t.string :duracao

      t.timestamps
    end
  end
end
