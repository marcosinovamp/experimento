require 'open-uri'
require 'nokogiri'
require 'csv'
require 'open_uri_redirections'
require 'resolv-replace'

servid = []

    html_data = URI.open("https://www.gov.br/pt-br/servicos/emitir-certidao-de-antecedentes-criminais").read
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
    servid << [id, cat1, cat2, cat3, ultmod, orgao, outserv.join(", "), descricao, solicitantes, nomes_etapas, descricao_etapas]

    puts servid