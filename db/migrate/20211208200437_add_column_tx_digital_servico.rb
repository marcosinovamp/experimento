class AddColumnTxDigitalServico < ActiveRecord::Migration[6.1]
  def change
    add_column :servicos, :taxa_digitalização, :float
  end
end
