class Documento < ApplicationRecord
    belongs_to :etapa
    has_one :service, through: :etapa
    has_one :orgao, through: :servico
end
