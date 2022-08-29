Rails.application.routes.draw do
  root to: 'main#home'
  get 'servico/index', to: 'servico#index'
  get 'servico/dados', to: 'servico#dados'
  get 'servico/listas', to: 'servico#listas'
  get 'servico/problemas', to: 'servico#problemas'
  get 'servico/:id', to: 'servico#show'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
