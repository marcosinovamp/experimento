class AddColumnOrgaoToProbPortal < ActiveRecord::Migration[6.1]
  def change
    add_column :prob_portals, :orgao, :string
  end
end
