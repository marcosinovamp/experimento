class Servico < ApplicationRecord
    belongs_to :orgao
    has_many :etapas
    has_many :canals, through: :etapas
    has_many :documentos, through: :etapas
    has_many :taxas, through: :etapas
end