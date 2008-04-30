# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

 def tiempo_restante
 	if session[:tiempo]
 		tiempo_restante = session[:tiempo] - Time.now 
		@restante = (tiempo_restante/60).round
		@restante
	else
		nil
	end
 end

end
