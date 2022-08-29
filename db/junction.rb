require 'open-uri'
require 'json'
require 'open_uri_redirections'
require 'resolv-replace'
require 'csv'

puts "Obtendo Dados da API"
resumo = Hash.new

apiservicos = JSON.parse(URI.open("https://www.servicos.gov.br/api/v1/servicos").read).first[1]

puts "Pronto!"
puts "Pinçando dados que desejamos da API"
servicos = {}
apiservicos.each do |serv|
    servicos[serv["id"].gsub("https://www.servicos.gov.br/api/v1/servicos/","")] = serv
end
       
servicos.each do |key,elm|
    av = elm["avaliacoes"].to_h
    resumo[key] = {nome: elm["nome"],sigla:elm["sigla"],contato:elm["contato"],gratuito?:elm["gratuito"],porcentagem_digital:elm["porcentagemDigital"],serviço_digital?:elm["servicoDigital"],link_btn_iniciar:elm["linkServicoDigital"],avaliacoes_positivas: av["positivas"],avaliacoes_negativas: av["negativas"], aprovacao: ((av["positivas"].to_i/(av["positivas"].to_f + av["negativas"].to_f))*100).round(2), descricao: elm["descricao"]}
    rk = resumo[key]
    
    rk[:orgao] = elm["orgao"]["nomeOrgao"]
    rk[:id_orgao] = elm["orgao"]["id"].gsub("http://estruturaorganizacional.dados.gov.br/id/unidade-organizacional/","")

    nompop = []
    [elm["nomesPopulares"].to_h["item"]].flatten.each do |x|
        nompop << x.to_a[0].to_a[1]
    end
    rk[:nomes_populares] = nompop - [""] - [nil]
    solic = {}
    [elm["solicitantes"].to_h["solicitante"]].flatten.each do |y|
        solic[y.to_a[1][1].to_sym] = y.to_a[2][1]
    end
    rk[:solicitantes] = solic
    tt = elm["tempoTotalEstimado"]
    at = tt["ate"]
    dc = tt[:descricao]
    en = tt["entre"]
    md = tt["emMedia"]
    if at != nil
        expressao = "até"
        rk[:duracao] = {expressao:expressao, max: at["max"], unidade: at["unidade"],observacoes: dc,sintese: "#{expressao} #{at["max"]} #{at["unidade"]}"}
    elsif en != nil
        expressao = "entre"
        rk[:duracao] = {expressao:expressao, min: en["min"], max:en["max"],unidade:en["unidade"],observacoes:dc, sintese: "#{expressao} #{en["min"]} e #{en["max"]} #{en["unidade"]}"}
    elsif md != nil
        expressao = "em média"
        rk[:duracao] = {expressao:expressao, max:md["max"],unidade:md["unidade"],observacoes:dc, sintese: "#{expressao} #{md["max"]} #{md["unidade"]}"}
    elsif tt["atendimentoImediato"] != nil
        rk[:duracao] = {expressao: "atendimento imediato", observacoes:dc, sintese:"atendimento imediato"}
    elsif tt["naoEstimadoAinda"] != nil
        rk[:duracao] = {expressao:"não estimado ainda",observacoes:dc,sintese:"não estimado ainda"}
    else
        rk[:duracao] = {expressao:"não informado",observacoes:dc,sintese:"não informado"}
    end
    segm = []
    elm["segmentosDaSociedade"]["item"].each do |seg|
        segm << seg["item"]
    end
    rk[:segmentos] = segm
    palavras_chave = []
    elm["palavrasChave"].to_h["item"].to_a.flatten.each do |word|
        palavras_chave << word["item"]
    end
    rk[:palavras_chave] = palavras_chave - [""]
    etapas = {}
    n = 1
    elm["etapas"].each do |x|
        documentos = {}
        casosdoc = {}
        dc = x["documentos"]
        if dc["documentos"] != nil
            dc["documentos"].each do |d|
                documentos[d["id"]] = d["nome"]
            end
        end
        dc["casos"].to_a.each do |c|
            tmp = []
            c["documento"].to_a.flatten.each do |z|
                tmp << z["descricao"]
            end
            casosdoc[c["descricao"].gsub(":","").to_sym] = tmp
        end
        custos = {}
        casos_taxas = {}
        ct = x["custos"]
        ct["custos"].to_a.flatten.each do |w|
            dk = w["id"]
            if w["statusCustoVariavel"] == 1
                custos[dk] = {descricao: w["descricao"], valor: w["valorVariavel"]}
            else
                custos[dk] = {descricao: w["descricao"], valor: "#{w["moeda"]} #{w["valor"]}"}
            end
        end
        ct["casos"].to_a.flatten.each do |t|
            dz = t["descricao"].to_sym
            t["custo"].each do |v|
                vd = v["descricao"]
                if v["statusCustoVariavel"] == 1
                    casos_taxas[dz] = "#{vd} - #{v["valorVariavel"]}"
                else
                    casos_taxas[dz] = "#{vd} - #{v["moeda"]} #{v["valor"]}"
                end
            end
        end
        canais_prestacao = {}
        casos_canais = {}
        b = 1
        cy = x["canaisDePrestacao"]
        cy["canaisDePrestacao"].each do |cha|
            canais_prestacao[cha["id"]] = {tipo_canal: cha["tipo"],descricao: cha["descricao"]}
            b += 1
        end
        cy["casos"].each do |csc|
            csc["canalDePrestacao"].each do |ono|
                casos_canais[csc["descricao"].to_sym] = {tipo_canal: ono["tipo"], descricao: ono["descricao"]}
            end
        end
        etapas[x["id"]] = {nome_etapa:x["titulo"],descricao_etapa:x["descricao"],documentos_etapa: {documentos: documentos,casos_especiais_doc: casosdoc},taxas: {custo: custos, casos_especiais_taxas: casos_taxas}, canais_de_prestacao: {canais: canais_prestacao, casos_especiais_canais: casos_canais}}
        n += 1
    end
    rk[:etapas] = etapas
    digit = []
    digitais = ["web", "e-mail", "aplicativo-movel", "web-consultar", "web-acompanhar", "web-preencher", "web-inscrever-se", "web-emitir", "web-declarar", "web-agendar", "web-calcular-taxas"]
    rk[:etapas].each do |chave,etapa|
        etapa[:canais_de_prestacao][:canais].each do |key,word|
            ww = word[:tipo_canal]
            if digitais.include?(ww)
                digit << [chave]
            end
        end
    end 
    rk[:qte] = rk[:etapas].length
    tipos_etapas = digit.group_by(&:itself).transform_values(&:count)
    rk[:qed] = tipos_etapas.length
end
puts "Pronto!"
puts "Abrindo arquivo servicos.csv"
portal = []
filepath = 'servicos.csv'
CSV.foreach(filepath) do |row|
    portal << row
end
puts "Pronto!"
puts "Incluindo dados do servico.csv nos dados de serviço."
trash = []
ne = 0
portal.each do |port|
    if port[12] != nil
        port[12] = port[12].split("\", \"")
    end
    if port[11] != nil
        port[11] = port[11].split("\", \"")
    end
    resumo.each do |id,val|
        if port[0].to_s == id.to_s
            if port[12].nil?
                port[12] = [""]*resumo[id][:etapas].length
            end
            if port[11].nil?
                port[11] = [""]*resumo[id][:etapas].length
            end
            resumo[id][:nome_portal] = port[1]
            resumo[id][:url] = port[2]
            resumo[id][:cat1] = port[3]
            resumo[id][:cat2] = port[4]
            resumo[id][:cat3] = port[5]
            resumo[id][:ult_mod] = port[6]
            resumo[id][:relacionados] = port[8]
            resumo[id][:desc_serv_port] = port[9]
            resumo[id][:solic_serv_port] = port[10]
            resumo[id][:etapas].each do |ke, ele|
                ele[:etp_nome] = port[11][ne]
                ele[:etp_desc] = port[12][ne]
                ne += 1
            end
            ne = 0
        else
            trash << 0
        end
    end
end
puts "Pronto!"
puts "Gravando dados no arquivo json"

filepath2 = 'servcomp.json'

File.open(filepath2, 'wb') do |file|
    file.write(JSON.generate(resumo, allow_nan: true))
end
puts "Feito!"