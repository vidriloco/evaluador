# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
  require 'iconv' 
class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_evaluacion_session_id'
  helper :errors
  CONTRASENA = 'Spalatin_1531'
  def to_iso(cadena)  
     c = Iconv.new('ISO-8859-15','UTF-8')  
     c.iconv(cadena)  
  end 
end
