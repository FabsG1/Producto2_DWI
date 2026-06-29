require 'sinatra'

set :port, 8000

UNIDADES = ["", "uno", "dos", "tres", "cuatro", "cinco", "seis", "siete", "ocho", "nueve"]
DECENAS = ["", "diez", "veinte", "treinta", "cuarenta", "cincuenta", "sesenta", "setenta", "ochenta", "noventa"]
ESPECIALES = ["diez", "once", "doce", "trece", "catorce", "quince", "dieciséis", "diecisiete", "dieciocho", "diecinueve"]
CENTENAS = ["", "cien", "doscientos", "trescientos", "cuatrocientos", "quinientos", "seiscientos", "setecientos", "ochocientos", "novecientos"]

def convertir_bloque(n)
  res = ""
  if n >= 100
    return "cien " if n == 100
    if n > 100 && n < 200
      res += "ciento "
    else
      res += CENTENAS[n / 100] + " "
    end
    n %= 100
  end
  
  if n >= 10 && n < 20
    res += ESPECIALES[n - 10] + " "
    return res
  elsif n >= 20
    return res + "veinte " if n == 20
    return res + "veinti" + UNIDADES[n % 10] + " " if n > 20 && n < 30
    
    res += DECENAS[n / 10]
    res += " y " + UNIDADES[n % 10] if n % 10 != 0
    res += " "
    return res
  end
  
  if n > 0 && n < 10
    res += UNIDADES[n] + " "
  end
  
  res
end

def numero_a_letras(n)
  return "cero" if n == 0
  resultado = ""

  if n >= 1000000
    millones = n / 1000000
    if millones == 1
      resultado += "un millón "
    else
      resultado += convertir_bloque(millones) + "millones "
    end
    n %= 1000000
  end
  
  if n >= 1000
    miles = n / 1000
    if miles == 1
      resultado += "mil "
    else
      resultado += convertir_bloque(miles) + "mil "
    end
    n %= 1000
  end
  
  resultado += convertir_bloque(n)
  resultado.strip
end

get '/' do
  content_type 'text/plain; charset=utf-8'
  query_param = params['n'] || "10"
  
  # Validación estricta con expresiones regulares para asegurar enteros
  if query_param.match?(/^\d+$/)
    numero_a_letras(query_param.to_i)
  else
    "Por favor, proporcione un número entero válido."
  end
end