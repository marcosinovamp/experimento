require 'open-uri'
require 'nokogiri'
require 'csv'
require 'open_uri_redirections'
require 'resolv-replace'

puts "fazendo os números"
servid = []
int = []
x = 0
servicos = []
until x > 990
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
        servicos << ["#{element.text.strip}","#{element.attribute('href').value}"]
    end
end
puts "Pronto!"
puts "Pegando as informações nas páginas."
servicos.each do |x|
    html_data = URI.open(x[1]).read
    nokogiri_object = Nokogiri::HTML(html_data)
   
    #id do serviço
    protopreid = nokogiri_object.xpath("//script[@type='text/javascript']")
    preid = protopreid.text.match(/"id":"\d+"/).to_s
    id = preid.gsub("\"id\":\"","").gsub("\"","")
   
    #categorias
    precat1 = nokogiri_object.xpath("//div[@class='header']//div//span[@class='title']")
    precat2 = nokogiri_object.xpath("//div[@class='header']//div//span[1]/a")
    precat3 = nokogiri_object.xpath("//div[@class='header']//div//span[3]/a")
    cat1 = precat1.text.strip
    cat2 = precat2.text.strip
    cat3 = precat3.text.strip
   
    #última modificação
    preultmod = nokogiri_object.xpath("//span[@class='documentModified']")
    ultmod = preultmod.text.gsub("Última Modificação: ","").strip
   
    # Órgão
    preorgao = nokogiri_object.xpath("//div[@class='conteudo']//div/span/a")
    orgao = preorgao.text.strip
    #descricao

    predescricao = nokogiri_object.xpath("//ul[@class='servico']/li[1]//div[@class='conteudo']")
    descricao = predescricao.text.strip
    
    #solicitantes
    presolicitantes = nokogiri_object.xpath("//ul[@class='servico']/li[2]//div[@class='conteudo']")
    solicitantes = presolicitantes.text.strip
    
    #etapas - nomes
    nomes_etapas = []
    prenomes_etapas = nokogiri_object.xpath("//ul[@class='servico']/li[3]//div[@class='conteudo']/ol/li/span")
    prenomes_etapas.each do |pne|
        nomes_etapas << pne.text.strip
    end
    
    #etapas - descricao
    descricao_etapas = []
    predescricao_etapas = nokogiri_object.xpath("//ul[@class='servico']/li[3]//div[@class='conteudo']/ol/li/div[1]")
    predescricao_etapas.each do |pde|
        descricao_etapas << pde.text.strip
    end
   
    #serviços relacionados
    preoutserv = nokogiri_object.xpath("//div[@class='itens']/a[@class='list-item']")
    outserv = []
    preoutserv.each do |pos|
        protopage = pos.attribute('href').text.strip
        prepage = URI.open(protopage).read
        page = Nokogiri::HTML(prepage)
        protoconteudo = page.xpath("//script[@type='text/javascript']")
        precounteudo = protoconteudo.text.match(/"id":"\d+"/).to_s
        conteudo = precounteudo.gsub("\"id\":\"","").gsub("\"","")
        outserv << conteudo
    end
    servid << [id, x[0], x[1], cat1, cat2, cat3, ultmod, orgao, outserv.join(", "), descricao, solicitantes, nomes_etapas, descricao_etapas]
end
puts "Pronto!"
puts "Gravando as informações no arquivo csv"
csv_options = { col_sep: ',', force_quotes: true, quote_char: '"' }
filepath    = 'servicos.csv'

CSV.open(filepath, 'wb', csv_options) do |csv|
  servid.each do |y|
    csv << y
  end
end
puts "Feito!"