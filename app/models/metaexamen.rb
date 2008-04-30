class Metaexamen < ActiveRecord::Base
	validates_presence_of :descriptor, :campana, :rubro, :area, :tiempo, :message => 'no debe de ir vacío.'
	validates_numericality_of :tiempo, :message => 'debe ser númerico.'
	has_many :examenes
	
	def agrega_pregunta pregunta
		pregunta_formato = pregunta + '|&&|'
		if self.preguntas
			self.preguntas << pregunta_formato		
		else
			self.preguntas = String.new
			self.preguntas << pregunta_formato	
		end
	end
	
	def desintetiza_preguntas
		if self.preguntas
			self.preguntas.split('|&&|')
		end
	end
	
	def count
	  if desintetiza_preguntas
	    desintetiza_preguntas.length
	  else
	    0
	  end
	end
	
	def self.todos_los_tipos
		todos = self.find(:all)
		@tipos = Array.new
		for metaexamen in todos
			@tipos << metaexamen.descriptor
		end
		@tipos
	end

end
