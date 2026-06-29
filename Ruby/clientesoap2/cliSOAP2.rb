require 'sinatra'
require 'savon'
require 'net/http'
require 'json'
require 'cgi'

set :port, 8000

get '/' do
  numero = params['n']
  
  begin
    # 1. Petición SOAP vía WSDL
    cliente = Savon.client(
      wsdl: "https://www.dataaccess.com/webservicesserver/NumberConversion.wso?WSDL",
      ssl_verify_mode: :none,
      log: false
    )
    
    respuesta_soap = cliente.call(:number_to_words, message: { "ubiNum" => numero })
    texto_ingles = respuesta_soap.body[:number_to_words_response][:number_to_words_result].to_s.strip
    
    # 2. Petición REST de Traducción
    # Usamos CGI.escape para los espacios y %7C para el pipe
    url_segura = "https://api.mymemory.translated.net/get?q=#{CGI.escape(texto_ingles)}&langpair=en%7Ces"
    uri = URI(url_segura)
    
    respuesta_rest = Net::HTTP.get_response(uri)
    
    # 3. Parseo JSON
    if respuesta_rest.is_a?(Net::HTTPSuccess)
      json = JSON.parse(respuesta_rest.body)
      texto_espanol = json['responseData']['translatedText'].downcase.strip
      
      content_type 'text/plain; charset=utf-8'
      texto_espanol
    else
      "Error en la API de traducción: Código #{respuesta_rest.code}"
    end
    
  rescue => e
    content_type 'text/plain; charset=utf-8'
    "Error general: #{e.message}"
  end
end