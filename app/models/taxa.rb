class Taxa < ApplicationRecord
    belongs_to :etapa
    has_one :servico, through: :etapa
    has_one :orgao, through: :etapa
end
