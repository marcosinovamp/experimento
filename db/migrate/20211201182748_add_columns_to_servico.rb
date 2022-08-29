class AddColumnsToServico < ActiveRecord::Migration[6.1]
  def change
    add_column :servicos, :solicitantes, :string
    add_column :servicos, :contato, :string
    add_column :servicos, :servicos_relacionados, :string
    add_column :servicos, :nomes_populares, :string
    add_column :servicos, :expressao_duracao, :string
    add_column :servicos, :min_duracao, :integer
    add_column :servicos, :max_duracao, :integer
    add_column :servicos, :unidade_duracao, :string
    add_column :servicos, :observacoes_duracao, :string
    add_column :servicos, :qtd_etapas_total, :integer
    add_column :servicos, :qtd_etapas_digitais, :integer
  end
end
