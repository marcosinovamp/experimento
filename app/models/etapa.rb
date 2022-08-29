class Etapa < ApplicationRecord
    belongs_to :servico
    has_many :documentos
    has_many :canals
    has_many :taxas
    has_one :orgao, through: :servico
end
