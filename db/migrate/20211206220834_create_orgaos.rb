class CreateOrgaos < ActiveRecord::Migration[6.1]
  def change
    create_table :orgaos do |t|
      t.string :nome

      t.timestamps
    end
  end
end
