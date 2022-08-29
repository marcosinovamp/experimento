class CreateUltimaAtualizacaos < ActiveRecord::Migration[6.1]
  def change
    create_table :ultima_atualizacaos do |t|
      t.date :data

      t.timestamps
    end
  end
end
