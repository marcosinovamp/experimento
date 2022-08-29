class ChangeColumnOrgaoOnServico < ActiveRecord::Migration[6.1]
  def change
    remove_column :servicos, :orgao
    add_reference :servicos, :orgao, null: false, foreign_key: true
  end
end
