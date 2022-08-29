class RenameNomesPopularesColumn < ActiveRecord::Migration[6.1]
  def change
    rename_column :servicos, :nomes_populares, :sigla
  end
end
