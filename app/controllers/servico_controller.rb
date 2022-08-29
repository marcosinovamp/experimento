class ServicoController < ApplicationController
  def index
    common
  end
  
  def show
    common
    @servico = Servico.find(params[:id])
    @etapas = Etapa.all.select {|c| c.servico_id == @servico.id}
    @orgao = Orgao.find(@servico.orgao_id)
    @avaliacoes_total = @servico.avaliacoes_positivas + @servico.avaliacoes_negativas
    @ind_aprov = ((@servico.avaliacoes_positivas.to_f/@avaliacoes_total)*100).round(2)
    @impacto_avaliacoes = (((@servico.avaliacoes_positivas.to_f/@soma_positivas_portal) - (@servico.avaliacoes_negativas.to_f/@soma_negativas_portal))*100).round(2)
    @dias_ultmod = (Date.today - @servico.data_modificacao).to_i
    @etotal = @servico.etapas.length
    @edigital = digitalize(@etapas)
    @ind_dig = ((@edigital.to_f/@etotal)*100).round(2)

    if @servico.nomes_populares.nil? || @servico.nomes_populares.empty?
      @nomes_populares = []
    else
      @nomes_populares = @servico.nomes_populares.to_s.gsub("[\"","").gsub("\"]","").split("\", \"")
    end

    if @servico.segmentos.nil? || @servico.segmentos.empty?
      @segmentos = []
    else
      @segmentos = @servico.segmentos.to_s.gsub("[\"","").gsub("\"]","").split("\", \"")
    end

    if @servico.palavras_chave.nil? || @servico.palavras_chave.empty?
      @palavras_chave = []
    else
      @palavras_chave = @servico.palavras_chave.to_s.gsub("[\"","").gsub("\"]","").split("\", \"")
    end
    selos  
  end

  def dados
    common
    @qtd_servicos = @servicos.length
    @servicos_com_avaliacao = 0 
    @total_gratuitos = 0
    @total_botao_solicitar = 0
    @qtd_etapas = 0
    @qtd_digitais = 0
    @tx_digital = 0
    @serv_total_digital = 0
    @servicos.each do |s|
      @total_gratuitos += s.gratuito == true ? 1 : 0
      @total_botao_solicitar += s.botao_solicitar == true ? 1 : 0
      @servicos_com_avaliacao += ((s.avaliacoes_positivas != nil ? s.avaliacoes_positivas : 0) + (s.avaliacoes_negativas != nil ? s.avaliacoes_negativas : 0)) > 0 ? 1 : 0
      @qtd_etapas += s.etapas.length
      @qtd_digitais += s.qtd_etapas_digitais
      @tx_digital += s.qtd_etapas_digitais.to_f/s.qtd_etapas_total
      @serv_total_digital += s.qtd_etapas_digitais == s.qtd_etapas_total ? 1 : 0
    end
  end
  
  def problemas
    common
    @problemas_portal = ProbPortal.all
    @semcat = @servicos.select {|sc| sc.categoria_nivel1.empty? || sc.categoria_nivel2.empty? || sc.categoria_nivel3.empty?}
  end
  
  def listas
    common
    @docs = []
    @documentos.each do |dd|
      @docs << dd.nome
    end
    @count_docs = @docs.group_by(&:itself).transform_values(&:count).sort_by {|k, v| -v}
    @serv_by_docs = {}
    @sbd = {}
    @teste = []
    @servicos.each do |serv|
      serv.etapas.each do |etp|
          @teste << etp.documentos
      end
      @serv_by_docs[serv.id] = @teste
      @teste = []
    end
    @serv_by_docs.each do |id, docs|
      @sbd[id] = docs.flatten.length
    end
    @list_org = []
    @orgaos.each do |o|
      @list_org << [o.servicos.length, o.nome]
    end
    @list_org = @list_org.sort {|x,y| -(x <=> y)}
  end


  private

  def digitalize(etapas)
      edigital = 0
      digitais = ["web", "e-mail", "aplicativo-movel", "web-consultar", "web-acompanhar", "web-preencher", "web-inscrever-se", "web-emitir", "web-declarar", "web-agendar", "web-calcular-taxas"]
      dd = 0
      etapas.each do |e|
        etapa = Etapa.find_by("api_id": e.api_id).id
        canais = Canal.all.select {|c| c.etapa_id == etapa}
          canais.each do |can|
            if digitais.include?(can.tipo)
              dd += 1
            end
          end
          if dd > 0
            edigital += 1
            dd = 0
          end
      end
      return edigital
  end

  def common
    @bruto = Servico.all
    @servicos = []
    @problemas = []
    @bruto.each do |b|
      if b.nome != nil
        @servicos << b
      else
        @problemas << b
      end
    end
    @orgaos = Orgao.all
    @documentos = Documento.all
    @canais = Canal.all
    @etapas = Etapa.all
    @total_avaliacoes_portal = 0
    @soma_positivas_portal = 0
    @soma_negativas_portal = 0
    @total_dias_atualizacao_portal = 0
    @não_atualizados_ano_ou_mais = 0
    @servicos.each do |s|
      @dias = (Date.today - s.data_modificacao).to_i
      @não_atualizados_ano_ou_mais += @dias > 365 ? 1 : 0
      @total_dias_atualizacao_portal += @dias
      @total_avaliacoes_portal += s.avaliacoes_positivas.to_i + s.avaliacoes_negativas.to_i
      @soma_positivas_portal += s.avaliacoes_positivas != nil ? s.avaliacoes_positivas : 0
      @soma_negativas_portal += s.avaliacoes_negativas != nil ? s.avaliacoes_negativas : 0
    end

    def selos
       # Início Selo Aprovação
      if @ind_aprov >= 80
        @apicone='laugh-beam'
        @class="otimo"
      elsif @ind_aprov > 60 && @ind_aprov < 80
        @apicone='smile-beam'
        @class="bom"
      elsif @ind_aprov >= 50 && @ind_aprov <= 60
        @apicone='meh'
        @class="medio"
      elsif @ind_aprov > 25 && @ind_aprov < 50
        @apicone='frown'
        @class="ruim"
      else
        @apicone='sad-cry'
        @class="pessimo"
      end
    # Fim Selo Aprovação
    # Inicio Selo Impacto
      if @impacto_avaliacoes > 0 
        @seta_impacto = 'arrow-alt-circle-up'
        @stilo = "otimo"
        @seta_impacto = 'minus-circle'
        @stilo = "medio"
      else
        @seta_impacto = 'arrow-alt-circle-down'
        @stilo = "pessimo"
      end
    # Fim Selo Impacto
    # Início Selo Atualização
      if @dias_ultmod <= 90
        @txt = "3 meses ou menos"
        @atualicon='laugh-beam'
        @nota="otimo"
      elsif @dias_ultmod > 90 && @dias_ultmod <= 180
        @txt = "Entre 3 e 6 meses"
        @atualicon='smile-beam'
        @nota="bom"
      elsif @dias_ultmod > 180 && @dias_ultmod <= 365
        @txt = "Entre 6 meses e 1 ano"
        @atualicon='meh'
        @nota="medio"
      elsif @dias_ultmod > 365 && @dias_ultmod <= 730
        @txt = "Entre 1 e 2 anos"
        @atualicon='frown'
        @nota="ruim"
      else
        @txt = "Mais de 2 anos"
        @atualicon='sad-cry'
        @nota="pessimo"
      end
    # Fim Selo Atualização
    # Início Selo Digitalização
      if @ind_dig >= 80
        @digicon='laugh-beam'
        @clss="otimo"
      elsif @ind_dig > 60 && @ind_dig < 80
        @digicon='smile-beam'
        @clss="bom"
      elsif @ind_dig >= 50 && @ind_dig <= 60
        @digicon='meh'
        @clss="medio"
      elsif @ind_dig > 25 && @ind_dig < 50
        @digicon='frown'
        @clss="ruim"
      else
        @digicon='sad-cry'
        @clss="pessimo"
      end
    # Fim Selo Digitalização
    end
  end

end