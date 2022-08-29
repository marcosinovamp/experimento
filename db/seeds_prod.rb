require 'json'
require 'open-uri'
require 'nokogiri'
require 'csv'

puts "Descobrindo a página final da lista"

file_html = URI.open("https://www.gov.br/pt-br/servicos").read
doc_html = Nokogiri::HTML(file_html)
last_page = (doc_html.xpath("//a[@class='pagina']").text.strip.to_i)*30

puts "Pronto"
puts "Fazendo os números"
servid =[]
int = []
portservicos = []
x = 0
until x > last_page
    int << x
    x += 30
end

puts "Pronto!"
puts "Pegando a lista de links."
int.each do |e|
    url = "https://www.gov.br/pt-br/servicos?b_start:int=#{e}"

    html_file = URI.open(url).read
    html_doc = Nokogiri::HTML(html_file)

    html_doc.search('.titulo').css('a').each do |element|
        portservicos << ["#{element.text.strip}","#{element.attribute('href').value}"]
    end
end
puts "Pronto!"
puts "Pegando as informações nas páginas."
portservicos.each do |x|
    html_data = URI.open(x[1]).read
    nokogiri_object = Nokogiri::HTML(html_data)
    #id do serviço
    pre = nokogiri_object.xpath("//script[@type='text/javascript']")
    almost = pre.text.match(/"id":"\d+"/).to_s
    id = almost.gsub("\"id\":\"","").gsub("\"","")
    #categorias
    cat = []
    ctg1 = nokogiri_object.xpath("//div[@class='header']//div//span[@class='title']")
    ctg2 = nokogiri_object.xpath("//div[@class='header']//div//span[1]/a")
    ctg3 = nokogiri_object.xpath("//div[@class='header']//div//span[3]/a")
    cat1 = ctg1.text.strip
    cat2 = ctg2.text.strip
    cat3 = ctg3.text.strip
    #última modificação
    mod = nokogiri_object.xpath("//span[@class='documentModified']")
    ultmod = mod.text.gsub("Última Modificação: ","").strip
    # Órgão
    org = nokogiri_object.xpath("//div[@class='conteudo']//div/span/a")
    orgao = org.text.strip
    #serviços relacionados
    serv = nokogiri_object.xpath("//div[@class='itens']/a[@class='list-item']")
    outserv = []
    serv.each do |s|
        limp = s.attribute('href').text.strip
        html_data = URI.open(limp).read
        nokogiri_object = Nokogiri::HTML(html_data)
        bring = nokogiri_object.xpath("//script[@type='text/javascript']")
        found = bring.text.match(/"id":"\d+"/).to_s
        idrel = found.gsub("\"id\":\"","").gsub("\"","")
        outserv << idrel
    end
     #descricao
     desc = nokogiri_object.xpath("//ul[@class='servico']/li[1]//div[@class='conteudo']")
     descricao = desc.text.strip
     #solicitantes
     solic = nokogiri_object.xpath("//ul[@class='servico']/li[2]//div[@class='conteudo']")
     solicitantes = solic.text.strip
     #etapas - nomes
     nomes_etapas = []
     etp_nom = nokogiri_object.xpath("//ul[@class='servico']/li[3]//div[@class='conteudo']/ol/li/span")
     etp_nom.each do |n|
         nomes_etapas << n.text.strip
     end
     #etapas - descricao
     descricao_etapas = []
     etp_dsc = nokogiri_object.xpath("//ul[@class='servico']/li[3]//div[@class='conteudo']/ol/li/div[1]")
     etp_dsc.each do |d|
         descricao_etapas << d.text.strip
     end
     servid << [id, x[0], x[1], cat1, cat2, cat3, ultmod, orgao, outserv.join(", "), descricao, solicitantes, nomes_etapas, descricao_etapas]
end
puts "Pronto!"
puts "Obtendo Dados da API"
resumo = Hash.new

apiservicos = JSON.parse(URI.open("https://www.servicos.gov.br/api/v1/servicos").read).first[1]

puts "Pronto!"
puts "Pinçando dados que desejamos da API"
aservicos = {}
apiservicos.each do |serv|
    aservicos[serv["id"].gsub("https://www.servicos.gov.br/api/v1/servicos/","")] = serv
end
       
aservicos.each do |key,elm|
    av = elm["avaliacoes"].to_h
    resumo[key] = {nome: elm["nome"],sigla:elm["sigla"],orgao:elm["orgao"]["nomeOrgao"],contato:elm["contato"],gratuito?:elm["gratuito"],porcentagem_digital:elm["porcentagemDigital"],serviço_digital?:elm["servicoDigital"],link_btn_iniciar:elm["linkServicoDigital"],avaliacoes_positivas: av["positivas"],avaliacoes_negativas: av["negativas"], aprovacao: ((av["positivas"].to_i/(av["positivas"].to_f + av["negativas"].to_f))*100).round(2), descricao: elm["descricao"]}
    # ids << key
    nompop = []
    [elm["nomesPopulares"].to_h["item"]].flatten.each do |x|
        nompop << x.to_a[0].to_a[1]
    end
    rk = resumo[key]
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
        documentos = []
        casosdoc = {}
        dc = x["documentos"]
        if dc["documentos"] != nil
            dc["documentos"].each do |d|
                documentos << d["nome"]
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
            dk = w["descricao"]
            if w["statusCustoVariavel"] == 1
                custos[dk.to_sym] = w["valorVariavel"]
            else
                custos[dk.to_sym] = "#{w["moeda"]} #{w["valor"]}"
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
            canais_prestacao[b] = {tipo_canal: cha["tipo"],descricao: cha["descricao"]}
            b += 1
        end
        cy["casos"].each do |csc|
            csc["canalDePrestacao"].each do |ono|
                casos_canais[csc["descricao"].to_sym] = {tipo_canal: ono["tipo"], descricao: ono["descricao"]}
            end
        end
        etapas[n] = {nome_etapa:x["titulo"],descricao_etapa:x["descricao"],documentos_etapa: {documentos: documentos,casos_especiais_doc: casosdoc},taxas: {custo: custos, casos_especiais_taxas: casos_taxas}, canais_de_prestacao: {canais: canais_prestacao, casos_especiais_canais: casos_canais}}
        n += 1
    end
    rk[:etapas] = etapas
    digit = []
    rk[:etapas].each do |chave,etapa|
        etapa[:canais_de_prestacao][:canais].each do |key,word|
            ww = word[:tipo_canal]
            if ww.include?("web") || ww.include?("aplicativo") || ww.include?("e-mail")
                digit << [chave, "digital"]
            end
        end
    end 
    rk[:qed] = 0
    rk[:qte] = rk[:etapas].length
    etapas_digitais = {}
    steps = *(1..rk[:qte])
    steps.each do |s|
        if digit.to_s.include?(s.to_s)
            etapas_digitais[s] = "digital"
        else
            etapas_digitais[s] = "não-digital"
        end
    end
    etapas_digitais.each do |k,e|
        if e == "digital"
            rk[:qed] += 1
        end
    end
end
puts "Pronto!"
puts "Unindo dados do portal com a api."
portal = servid
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
puts "Iniciando o processo de seed"

puts "Apagando dados antigos"

Canal.destroy_all
Documento.destroy_all
Taxa.destroy_all
Etapa.destroy_all
Servico.destroy_all
Orgao.destroy_all

servicos = resumo

puts "Iniciando seed dos Órgãos"
servicos.each do |k,s|
    if Orgao.find_by("nome": s["orgao"]).nil?
        Orgao.create(nome: s["orgao"])
    else
        Orgao.find_by("nome": s["orgao"]).nome = s["orgao"]
    end
end

puts "Iniciando seed dos Serviços"
servicos.each do |key, serv|
    Servico.create(api_id: key, nome: serv["nome_portal"], url: serv["url"], categoria_nivel1: serv["cat1"], categoria_nivel2: serv["cat2"], categoria_nivel3: serv["cat3"], data_modificacao: serv["ult_mod"], orgao_id: Orgao.find_by("nome": serv["orgao"]).id, sigla: serv["sigla"], botao_solicitar: serv["serviço_digital?"], link_botaosolicitar: serv["link_btn_iniciar"], gratuito: serv["gratuito?"], descricao: serv["descricao"], avaliacoes_positivas: serv["avaliacoes_positivas"], avaliacoes_negativas: serv["avaliacoes_negativas"], segmentos: serv["segmentos"], palavras_chave: serv["palavras_chave"], duracao: serv["duracao"]["sintese"], solicitantes: serv["solicitantes"], contato: serv["contato"], servicos_relacionados: serv["relacionados"], nomes_populares: serv["nomes_populares"], expressao_duracao: serv["duracao"]["expressao"], min_duracao: serv["duracao"]["min"], max_duracao: serv["duracao"]["max"], unidade_duracao: serv["duracao"]["unidade"], observacoes_duracao: serv["duracao"]["observacoes"], qtd_etapas_total: serv["qte"], qtd_etapas_digitais: serv["qed"], serv_desc_portal: serv["desc_serv_port"], serv_solic_portal: serv["solic_serv_port"])
end

puts "Iniciando seed das Etapas"
number = 1
servicos.each do |ch, dado|
    dado["etapas"].each do |n,cont|
        Etapa.create(nome: cont["nome_etapa"], descricao: cont["descricao_etapa"], nb: number, nome_etapa_portal: cont["etp_nome"], descricao_etapa_portal: cont["etp_desc"], servico_id: Servico.find_by("api_id":ch).id)
        number += 1    
    end
end

puts "Iniciando seeds dos documentos, canais e taxas"
fn = 1
servicos.each do |cc, dd|
    dd["etapas"].each do |nn,ct|
        if ct["documentos_etapa"]["documentos"] != nil
            ct["documentos_etapa"]["documentos"].each do |doc|
                Documento.create(nome: doc, etapa_id: Etapa.find_by("nb":fn).id)
            end
        end
        ct["canais_de_prestacao"]["canais"].each do |cank, cancon|
            Canal.create(tipo: cancon["tipo_canal"], descricao: cancon["descricao"], etapa_id: Etapa.find_by("nb":fn).id)
        end
        if ct["taxas"]["custo"] != nil
            ct["taxas"]["custo"].each do |taxkey, taxelm|
                Taxa.create(descricao: taxkey, valor: taxelm, etapa_id: Etapa.find_by("nb":fn).id)
            end
        end
        fn += 1
    end
end

puts "Determinando a data de atualização"

UltimaAtualizacao.create(data: Date.today)

puts "Feito!"