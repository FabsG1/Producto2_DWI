require 'sinatra'
require 'savon'

set :port, 8000

get '/' do
  numero = params['n']
  
  begin
    # 1. Instanciamos el cliente pasándole directamente el contrato WSDL
    cliente = Savon.client(
      wsdl: "https://www.dataaccess.com/webservicesserver/NumberConversion.wso?WSDL",
      ssl_verify_mode: :none, # Evadir bloqueo de certificados locales
      open_timeout: 60,
      read_timeout: 60,
      log: false # Apagamos el log para no saturar la consola
    )
    
    # 2. Savon convierte el símbolo :number_to_words en la etiqueta XML correspondiente
    respuesta = cliente.call(:number_to_words, message: { "ubiNum" => numero })
    
    # 3. Extraer resultado del hash de respuesta
    resultado = respuesta.body[:number_to_words_response][:number_to_words_result]
    
    content_type 'text/plain; charset=utf-8'
    resultado.to_s.strip
    
  rescue => e
    content_type 'text/plain; charset=utf-8'
    "Error SOAP (WSDL): #{e.message}"
  end
end