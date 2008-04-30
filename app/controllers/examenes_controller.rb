class ExamenesController < ApplicationController
	layout 'general'
  def index
    registro
    render :action => 'registro'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def registro
    @examen = Examen.new
  end

  def show
    @examen = Examen.find(params[:id])
  end

  def evaluacion
    session[:aspirante] = Aspirante.new :nombre => params[:nombre], 
    											:supervisor => params[:supervisor], :fecha => Date.today
    @tipo = params[:tipo]
    @metaexamen = Metaexamen.find(:first, :conditions => "descriptor = '#{@tipo}'")
    cookies[:metaexamen_id] = @metaexamen.id.to_s
    render :template => 'examenes/examen'
  end

	def tiempo_que_falta
		tiempo_restante = session[:tiempo] - Time.now
		@restante = (tiempo_restante/60)
		@restante
	end
	
	def sincroniza
		@restante = tiempo_que_falta
		senal_guardar = Range.new 0, 0.9
		senal_alerta = Range.new 1, 10
		if senal_guardar === @restante
			@respuestas = session[:contenedor_de_respuestas].to_formato_de_respuestas
	  	guarda_examen @respuestas
		else
			render :update do |page|
				page.replace_html 'mensajes', "<p>Te restan #{@restante.round} minutos.</p>"
				page.visual_effect :appear, 'mensajes'
				if @restante <= 5
					page.replace_html 'alerta', "<p>Verifica tus respuestas y termina de contestar las que puedan hacerte falta.</p>"
					page.visual_effect :appear, 'alerta'
				end
			end
		end
	end

	def guarda_examen respuestas
			@examen = Examen.new :respuestas => respuestas, :fecha => session[:aspirante].fecha,  
							 :nombre => session[:aspirante].nombre, :supervisor => session[:aspirante].supervisor,
							 :metaexamen_id => cookies[:metaexamen_id]
			@examen.save
			render :update do |page|
				page.replace_html 'sustituible', 
				"<h5 class='centrado'>Tu examen ha sido guardado, los resultados se te proporcionarán más adelante.</h5>"
	  	end
			limpia_todo
	end
	
	def protege_respuestas
		@preguntas_length = session[:contenedor_de_respuestas].numero_de_preguntas
		i=0
		while i <= @preguntas_length
			unless params["#{i}"].blank?
				session[:contenedor_de_respuestas].agrega_respuesta i, params["#{i}"]				
				break
			end
			i = i+1
		end
		#debugger
		render :nothing => true
	end

	def prepara_examen
		metaexamen = Metaexamen.find(params[:id])
		@preguntas = metaexamen.desintetiza_preguntas
		if session[:tiempo].nil? 
    	session[:tiempo] = metaexamen.tiempo.minutes.from_now.change(:sec => 00)
    end
		render :update do |page|
			if @preguntas.blank?
				page.replace_html 'examen_preguntas', 
								          "<br/><h5 class='centrado'>No hay preguntas que contestar para éste exámen.</h5>"
			else
				session[:contenedor_de_respuestas] =  ContenedorDeRespuestas.new @preguntas.length-1
				page.replace_html 'examen_preguntas', :partial => 'respuestas', :object => @preguntas, 
												:locals => {:metaexamen => metaexamen}
				page.visual_effect :appear, 'examen_preguntas'
			end
		end
	end
	
	def integra_respuestas
		@preguntas_length = session[:contenedor_de_respuestas].numero_de_preguntas
		@respuestas = String.new
		i=0
		while i <= @preguntas_length
			if params["#{i}"].blank?
  			@respuestas << "---" << "|&&|"
			else
				@respuestas << params["#{i}"] << "|&&|"
			end
			i=i+1
		end
		guarda_examen @respuestas
	end
	
	def limpia_todo
		session[:aspirante] = nil
		session[:tiempo] = nil
		cookies[:metaexamen_id] = nil
	end
	
	def limpieza
		limpia_todo
		render :update do |page|
			page.replace_html 'limpieza', "<p class='centrado'>Es seguro continuar con las evaluaciones.</p>"
			page.visual_effect :highlight, 'limpieza', :duration => 5
		end
	end
	
	def contrasena_acceso
		case params[:id].to_i	
			when 0
				render :update do |page|
					page.replace_html 'boton_para_c', :partial => 'contrasena_acceso', :locals => {:mensaje => ""}
					page.visual_effect :highlight, 'boton_para_c', :duration => 5
					page.visual_effect :appear, 'boton_para_c'
				end
			when 1
				render :update do |page|
					if params['contrasena'].eql? CONTRASENA
						page.replace_html 'boton_para_c', :partial => 'boton_limpiador'
					else
						page.replace_html 'boton_para_c', :partial => 'contrasena_acceso'
					end
				end
			when 2
				render :update do |page|
					page.visual_effect :fade, 'boton_para_c'
				end
		end
	end
end
