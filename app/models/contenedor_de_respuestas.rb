class ContenedorDeRespuestas

	attr_reader :numero_de_preguntas
	
	def initialize numero_de_preguntas
		@numero_de_preguntas = numero_de_preguntas
		@rango_to_a = Range.new(0, @numero_de_preguntas).to_a 
		@contenedor = Hash.new
	end
	
	def agrega_respuesta key, valor
		@contenedor[key] = valor
	end
	
	def to_formato_de_respuestas
		@respuestas = String.new
		unless @rango_to_a.eql? @contenedor.keys
			@rango_to_a.each do |elemento|
				unless @contenedor.keys.member? elemento
					@contenedor[elemento] = '---'
				end
			end
		end
		@contenedor.keys.sort!.each do |key|
			@respuestas << @contenedor[key] << '|&&|'
		end
		@respuestas
	end
	
	def reinicializar
		@contenedor = Hash.new
	end

end
