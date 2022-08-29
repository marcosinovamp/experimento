class Orgao < ApplicationRecord
    has_many :servicos
    has_many :etapas, through: :servicos
    has_many :canals, through: :etapas
    has_many :documentos, through: :etapas
    has_many :taxas, through: :etapas
end
