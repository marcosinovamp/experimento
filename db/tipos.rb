require 'json'

filepath = "servcomp.json"
bruto = File.read(filepath)
servicos = JSON.parse(bruto, allow_nan:true)

tipos = []
final_tipos = []
servicos.each do |key, element|
    element["etapas"].each do |ke, ee|
        ee["canais_de_prestacao"]["canais"].each do |kc, ec|
            tipos << ec["tipo_canal"]
        end
    end
end

final_tipos = tipos.group_by(&:itself).transform_values(&:count).sort_by {|k, v| -v}

final_tipos.each do |t|
    puts t[0]
end