class AddServicoToEtapas < ActiveRecord::Migration[6.1]
  def change
    add_reference :etapas, :servico, null: false, foreign_key: true
  end
end
