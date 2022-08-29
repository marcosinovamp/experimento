class CreateTaxas < ActiveRecord::Migration[6.1]
  def change
    create_table :taxas do |t|
      t.string :descricao
      t.string :valor

      t.timestamps
    end
  end
end
