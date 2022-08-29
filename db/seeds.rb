require 'json'
require 'csv'

Canal.destroy_all
Documento.destroy_all
Taxa.destroy_all
Etapa.destroy_all
Servico.destroy_all
Orgao.destroy_all

filepath = "db/servcomp.json"
bruto = File.read(filepath)
servicos = JSON.parse(bruto, allow_nan:true)

servicos.each do |k,s|
    Orgao.create(nome: s["orgao"], api_id: s["id_orgao"])
end

cad = []
servicos.each do |key, serv|
    Servico.create(api_id: key, nome: serv["nome_portal"], url: serv["url"], categoria_nivel1: serv["cat1"], categoria_nivel2: serv["cat2"], categoria_nivel3: serv["cat3"], data_modificacao: serv["ult_mod"], orgao_id: Orgao.find_by("nome": serv["orgao"]).id, sigla: serv["sigla"], botao_solicitar: serv["serviço_digital?"], link_botaosolicitar: serv["link_btn_iniciar"], gratuito: serv["gratuito?"], descricao: serv["descricao"], avaliacoes_positivas: serv["avaliacoes_positivas"], avaliacoes_negativas: serv["avaliacoes_negativas"], segmentos: serv["segmentos"], palavras_chave: serv["palavras_chave"], duracao: serv["duracao"]["sintese"], solicitantes: serv["solicitantes"], contato: serv["contato"], servicos_relacionados: serv["relacionados"], nomes_populares: serv["nomes_populares"], expressao_duracao: serv["duracao"]["expressao"], min_duracao: serv["duracao"]["min"], max_duracao: serv["duracao"]["max"], unidade_duracao: serv["duracao"]["unidade"], observacoes_duracao: serv["duracao"]["observacoes"], qtd_etapas_total: serv["qte"], qtd_etapas_digitais: serv["qed"], serv_desc_portal: serv["desc_serv_port"], serv_solic_portal: serv["solic_serv_port"], nome_api: serv["nome"])
    cad << key
end

number = 1
servicos.each do |ch, dado|
    dado["etapas"].each do |n,cont|
        Etapa.create(nome: cont["nome_etapa"], descricao: cont["descricao_etapa"], nb: number, nome_etapa_portal: cont["etp_nome"], descricao_etapa_portal: cont["etp_desc"], servico_id: Servico.find_by("api_id":ch).id, api_id: n)
        number += 1    
    end
end

fn = 1
servicos.each do |cc, dd|
    dd["etapas"].each do |nn,ct|
        if ct["documentos_etapa"]["documentos"] != nil
            ct["documentos_etapa"]["documentos"].each do |kdoc, doc|
                Documento.create(nome: doc, etapa_id: Etapa.find_by("api_id":nn).id, api_id: kdoc)
            end
        end
        ct["canais_de_prestacao"]["canais"].each do |cank, cancon|
            Canal.create(tipo: cancon["tipo_canal"], descricao: cancon["descricao"], etapa_id: Etapa.find_by("api_id":nn).id, api_id:cank)
        end
        if ct["taxas"]["custo"] != nil
            ct["taxas"]["custo"].each do |taxkey, taxelm|
            Taxa.create(descricao: taxelm["descricao"], valor: taxelm["valor"], etapa_id: Etapa.find_by("api_id":nn).id, api_id: taxkey)
            end
        end
        fn += 1
    end
end

portal = []
filep = 'db/servicos.csv'
CSV.foreach(filep) do |row|
    portal << row
end

portal.each do |p|
    if p[0].nil? == false && p[0].empty? == false && cad.include?(p[0]) == false
        ProbPortal.create(api_id: p[0], nome: p[1], url: p[2], ultmod: p[6], orgao: p[7])
    end
end

UltimaAtualizacao.create(data: Date.today)