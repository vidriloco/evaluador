class MetaexamenesController < ApplicationController
	layout 'general'
  def index
    list
    render :action => 'list'
  end

	Metaexamen.content_columns.each do |column|
	  in_place_edit_for :metaexamen, column.name
	end


  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @metaexamen_pages, @metaexamenes = paginate :metaexamenes, :per_page => 10
    @examen_pages, @examenes = paginate :examenes, :per_page => 10
  end

  def new
    @metaexamen = Metaexamen.new
  end

  def crear_formato
		@metaexamen = Metaexamen.new(params[:metaexamen])
		if @metaexamen.save
		  redirect_to :action => 'list'
	  else
		  render :action => 'new'
		end
  end

	def pregunta_form
	  @metaexamen = Metaexamen.find(params[:id])
		render :update do |page|
			page.replace_html "forma_pregunta#{@metaexamen.id}", :partial => 'pregunta_form', 
			                  :object => @metaexamen
			if params[:n].eql? 'sin_p'
				page.visual_effect :fade, "no_preguntas#{@metaexamen.id}"
				page.insert_html :top, "solo_en_vacio#{@metaexamen.id}", "<ul id='listado#{@metaexamen.id}' class='lista' style='display:none'></ul>"
			end
			page.visual_effect :appear, "forma_pregunta#{@metaexamen.id}"
		end
	end

	def agrega_pregunta
		metaexamen = Metaexamen.find(params[:id])
		@pregunta = params[:pregunta]
		preguntas_numero = metaexamen.count
		if metaexamen.count == 0
		  @indice = 0
		else
  		@indice = metaexamen.count+1
  	end
		session[:contenedor_de_preguntas][params[:id]].agrega @indice, @pregunta
		metaexamen.preguntas = session[:contenedor_de_preguntas][params[:id]].to_formato_de_preguntas
		metaexamen.update
		@preguntas = metaexamen.desintetiza_preguntas
		render :update do |page|
		  if preguntas_numero == 0
		    page.replace_html "preguntas#{metaexamen.id}", :partial => 'si_hay_preguntas', 
		      :object => @preguntas, :locals => {:metaexamen => metaexamen}
			  page.visual_effect :appear, "preguntas#{metaexamen.id}"
			  page.replace_html "forma_pregunta#{metaexamen.id}", :partial => 'pregunta_form', :object => metaexamen
		  else
			  page.insert_html :bottom, "listado#{metaexamen.id}", :partial => 'pregunta_en_lista', 
			                   :object => @indice, :locals => {:pregunta => @pregunta, :metaexamen => metaexamen.id}

			  page.replace_html "forma_pregunta#{metaexamen.id}", :partial => 'pregunta_form', :object => metaexamen
			end
		end
	end

  def agrega_contenedor_al_contenedor id, contenedor
    if session[:contenedor_de_preguntas].nil?
      session[:contenedor_de_preguntas] = {id => contenedor}
    else
      session[:contenedor_de_preguntas][id] = contenedor
    end
  end

	def despliega_preguntas
		formato = Metaexamen.find(params[:id])
		@preguntas = formato.desintetiza_preguntas
		@contenedor = ContenedorDePreguntas.new @preguntas
		agrega_contenedor_al_contenedor params[:id], @contenedor
		render :update do |page|
			page.replace_html 'preguntasg' + params[:id], :partial => 'preguntas', :object => @preguntas, 
			:locals => {:metaexamen => formato} 
			page.visual_effect :appear, 'preguntasg' + params[:id]
		end
	end
	
  def edit
    @metaexamen = Metaexamen.find(params[:id])
  end
	
	def eliminar_examen
		@id = params[:id]
		Examen.find(@id).destroy
		render :update do |page|
			if Examen.count == 0
				page.replace_html 'lista_examenes', "<br/><h5 class='justificado_centrado'>No hay exámenes de aplicantes en éste momento.</h5>"
				page.visual_effect :appear, 'lista_examenes'
			else
				page.visual_effect :fade, "examen#{@id}"	
			end
		end
	end
	
  def update
    @metaexamen = Metaexamen.find(params[:id])
    if @metaexamen.update_attributes(params[:metaexamen])
      flash[:notice] = 'Metaexamen was successfully updated.'
      redirect_to :action => 'show', :id => @metaexamen
    else
      render :action => 'edit'
    end
  end

  def destroy
    Metaexamen.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def develar_respuestas
  	@res  =  prepara_datos_de_examen_y_metaexamen params[:id]
  	@examen = @res[:examen]
  	preguntas = @res[:preguntas]
  	respuestas = @res[:respuestas]
  	render :update do |page|
  		page.replace_html 'respuestas_examenes', :partial => 'respuestas_examenes', 
  		:locals => {:preguntas => preguntas, :respuestas => respuestas}, :object => @examen
  	end
  end
  
  def prepara_datos_de_examen_y_metaexamen id
    examen = Examen.find(:first, id)
  	metaexamen = examen.metaexamen
  	preguntas = metaexamen.desintetiza_preguntas
  	respuestas = examen.desintetiza_respuestas
  	return Hash[:examen => examen, :preguntas => preguntas, :respuestas => respuestas]
  end
  
  def a_pdf
    @res  =  prepara_datos_de_examen_y_metaexamen params[:id]
  	@examen = @res[:examen]
  	preguntas = @res[:preguntas]
  	respuestas = @res[:respuestas]
  	p = PDF::Writer.new(:paper => "A4")
 		p.select_font('Helvetica-Oblique', :encoding => nil)
 		p.text to_iso(@examen.metaexamen.descriptor.upcase), :font_size => 15, :justification => :center, 
 		:spacing => 1
 		p.text to_iso("NOMBRE: " + @examen.nombre + " SUPERVISOR: " + @examen.supervisor), :font_size => 11, :justification => :left, :spacing => 5
 		@num_de_preguntas = preguntas.length-1
 		i=0
 		while i <= @num_de_preguntas
 			p.text "#{i+1}.-" << to_iso(preguntas[i]), :font_size => 12, :spacing => 2, :justification => :left
 			p.text to_iso(respuestas[i]), :font_size => 10, :spacing => 1, :justification => :left
 			i=i+1
 		end
 		 @filename = @examen.metaexamen.descriptor + ' - ' + @examen.nombre
	   send_data p.render, :filename => to_iso(@filename) , :type => "application/pdf" 
  end
  
  def cerrar
  	@metaexamen = Metaexamen.find(params[:id])
  	render :update do |page|
  	  if @metaexamen.count == 0 
  	    page.visual_effect :fade, "forma_pregunta#{@metaexamen.id}"
  	    page.replace_html "preguntas#{@metaexamen.id}" , :partial => 'no_hay_preguntas', 
          :locals => {:metaexamen => @metaexamen}
  	  else
  		  page.visual_effect :fade, "forma_pregunta#{@metaexamen.id}"
  		end
  	end
  end
  
  def cerrar_listado
  	@id = params[:id]
  	session[:contenedor_de_preguntas].delete @id
  	render :update do |page|
  		page.visual_effect :fade, "preguntasg#{@id}"
  	end

  end
  
  def elimina_pregunta
    @ids = params[:id].split
    @indice_de_pregunta = @ids[0]
    @id_metaexamen = @ids[1]
    @metaexamen = Metaexamen.find(@id_metaexamen)
    session[:contenedor_de_preguntas][@id_metaexamen].elimina @indice_de_pregunta.to_i
    nuevas_preguntas = session[:contenedor_de_preguntas][@id_metaexamen].to_formato_de_preguntas
    @metaexamen.preguntas = nuevas_preguntas
    if @metaexamen.update
      render :update do |page|
        if @metaexamen.count == 0
          page.replace_html "preguntas#{@id_metaexamen}", :partial => 'no_hay_preguntas', 
          :locals => {:metaexamen => @metaexamen} 
          page.visual_effect :fade, "solo_en_vacio#{@metaexamen.id}"
          page.visual_effect :appear, "preguntas#{@metaexamen.id}"
       else
          page.visual_effect :fade, "#{@indice_de_pregunta}#{@metaexamen.id}preg"
        end
      end    
    end
  end 
end
