class ContenedorDePreguntas

  def initialize preguntas
    @preguntas = preguntas
    @diccionario = Hash.new
    indice = 0
    unless @preguntas.blank?
      @preguntas.each do |pregunta|
        @diccionario[indice] = pregunta
        indice = indice + 1
      end
    end
  end
  
  def agrega indice, pregunta
    @diccionario[indice] = pregunta
  end
  
  def modifica indice, pregunta
    if pregunta.blank?
      @diccionario.delete indice
    else
      @diccionario[indice] = pregunta
    end
  end
  
  def to_formato_de_preguntas
    @resultado = String.new
    @diccionario.each_value do |elemento|
      @resultado << elemento << "|&&|"
    end
    @resultado
  end
  
  def elimina indice
    @diccionario.delete indice
  end

end
