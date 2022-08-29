class AddColumnDigitalToCanal < ActiveRecord::Migration[6.1]
  def change
    add_column :canals, :digital, :boolean
  end
end
