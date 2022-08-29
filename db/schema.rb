# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_12_09_012309) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "canals", force: :cascade do |t|
    t.string "tipo"
    t.string "descricao"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "etapa_id", null: false
    t.integer "api_id"
    t.boolean "digital"
    t.index ["etapa_id"], name: "index_canals_on_etapa_id"
  end

  create_table "documentos", force: :cascade do |t|
    t.text "nome"
    t.integer "etapa_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "api_id"
    t.index ["etapa_id"], name: "index_documentos_on_etapa_id"
  end

  create_table "etapas", force: :cascade do |t|
    t.string "nome"
    t.string "descricao"
    t.boolean "digital"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "servico_id", null: false
    t.integer "nb"
    t.string "nome_etapa_portal"
    t.string "descricao_etapa_portal"
    t.integer "api_id"
    t.index ["servico_id"], name: "index_etapas_on_servico_id"
  end

  create_table "orgaos", force: :cascade do |t|
    t.string "nome"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "api_id"
  end

  create_table "prob_portals", force: :cascade do |t|
    t.integer "api_id"
    t.string "nome"
    t.string "url"
    t.string "ultmod"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "orgao"
  end

  create_table "servicos", force: :cascade do |t|
    t.string "nome"
    t.string "url"
    t.integer "api_id"
    t.string "categoria_nivel1"
    t.string "categoria_nivel2"
    t.string "categoria_nivel3"
    t.date "data_modificacao"
    t.string "sigla"
    t.boolean "botao_solicitar"
    t.string "link_botaosolicitar"
    t.boolean "gratuito"
    t.string "descricao"
    t.integer "avaliacoes_positivas"
    t.integer "avaliacoes_negativas"
    t.string "segmentos"
    t.string "palavras_chave"
    t.string "duracao"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "solicitantes"
    t.string "contato"
    t.string "servicos_relacionados"
    t.string "nomes_populares"
    t.string "expressao_duracao"
    t.integer "min_duracao"
    t.integer "max_duracao"
    t.string "unidade_duracao"
    t.string "observacoes_duracao"
    t.integer "qtd_etapas_total"
    t.integer "qtd_etapas_digitais"
    t.integer "docqtd"
    t.string "serv_desc_portal"
    t.string "serv_solic_portal"
    t.bigint "orgao_id", null: false
    t.string "nome_api"
    t.float "taxa_digitalização"
    t.index ["orgao_id"], name: "index_servicos_on_orgao_id"
  end

  create_table "taxas", force: :cascade do |t|
    t.string "descricao"
    t.string "valor"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "etapa_id", null: false
    t.integer "api_id"
    t.index ["etapa_id"], name: "index_taxas_on_etapa_id"
  end

  create_table "ultima_atualizacaos", force: :cascade do |t|
    t.date "data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "canals", "etapas"
  add_foreign_key "etapas", "servicos"
  add_foreign_key "servicos", "orgaos"
  add_foreign_key "taxas", "etapas"
end
