class Aspirante
	
	attr_reader :nombre, :supervisor, :fecha
	
	def initialize arg
		@nombre = arg[:nombre]
		@supervisor = arg[:supervisor]
		@fecha = arg[:fecha]
	end
	
	def to_examen
		return Examen.new :nombre => @nombre, :supervisor => @supervisor, :fecha => @fecha
	end
	
end
