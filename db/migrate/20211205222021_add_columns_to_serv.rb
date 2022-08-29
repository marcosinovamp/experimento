class AddColumnsToServ < ActiveRecord::Migration[6.1]
  def change
    add_column :servicos, :serv_desc_portal, :string
    add_column :servicos, :serv_solic_portal, :string
  end
end
