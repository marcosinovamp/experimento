class CreateProbPortals < ActiveRecord::Migration[6.1]
  def change
    create_table :prob_portals do |t|
      t.integer :api_id
      t.string :nome
      t.string :url
      t.string :ultmod

      t.timestamps
    end
  end
end
