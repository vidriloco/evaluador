class Examen < ActiveRecord::Base
	belongs_to :metaexamen
	
	def desintetiza_respuestas
		if self.respuestas
			self.respuestas.split('|&&|')
		end
	end
end
