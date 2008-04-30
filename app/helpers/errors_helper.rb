module ErrorsHelper
  
	def error_messages_for(*params)
	  options = params.last.is_a?(Hash) ? params.pop.symbolize_keys : {}
	  objects = params.collect {|object_name| instance_variable_get("@#{object_name}") }.compact
	#  objects = renombra objects, {:descriptor => 'descripción_del_formato', :campana => 'campaña'}
	  count   = objects.inject(0) {|sum, object| sum + object.errors.count }
	  unless count.zero?
	    html = {}
	    [:id, :class].each do |key|
	      if options.include?(key)
	        value = options[key]
	        html[key] = value unless value.blank?
	      else
	        html[key] = 'errorExplanation'
	      end
	  end
	    header_message = "#{pluralize(count, 'error')} impidieron guardar éste formato"
	    error_messages = objects.map {|object| object.errors.full_messages.map {|msg| content_tag(:li, msg) } }
	    error_messages = renombra error_messages, {:Descriptor => 'Descripción del formato', :Area => 'Área', :Campana => 'Campaña'}
	    content_tag(:div,
	    content_tag(options[:header_tag] || :h2, header_message) <<
	    content_tag(:p, 'Hubo problemas en los siguientes campos:') <<
	    content_tag(:ul, error_messages),
	    html  )
	  else
	   ''
	  end
  end
  
  def renombra arreglo_de_mensajes, hash_n 
  	arreglo_de_mensajes[0].each do |mensaje|
  		hash_n.each_key do |key|
  			if mensaje.include? key.to_s
  				mensaje.sub! key.to_s, hash_n[key]
  			end
  		end
  	end
  	arreglo_de_mensajes
  end
end 


