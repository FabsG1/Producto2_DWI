package main

import (
	"fmt"
	"net/http"
	"strconv"
	"strings"
)

var (
	unidades   = []string{"", "uno", "dos", "tres", "cuatro", "cinco", "seis", "siete", "ocho", "nueve"}
	decenas    = []string{"", "diez", "veinte", "treinta", "cuarenta", "cincuenta", "sesenta", "setenta", "ochenta", "noventa"}
	especiales = []string{"diez", "once", "doce", "trece", "catorce", "quince", "dieciséis", "diecisiete", "dieciocho", "diecinueve"}
	centenas   = []string{"", "cien", "doscientos", "trescientos", "cuatrocientos", "quinientos", "seiscientos", "setecientos", "ochocientos", "novecientos"}
)

func convertirBloque(n int) string {
	res := ""
	if n >= 100 {
		if n == 100 {
			return "cien "
		}
		if n > 100 && n < 200 {
			res += "ciento "
		} else {
			res += centenas[n/100] + " "
		}
		n %= 100
	}
	if n >= 10 && n < 20 {
		res += especiales[n-10] + " "
		return res
	} else if n >= 20 {
		if n == 20 {
			return res + "veinte "
		}
		if n > 20 && n < 30 {
			return res + "veinti" + unidades[n%10] + " "
		}
		res += decenas[n/10]
		if n%10 != 0 {
			res += " y " + unidades[n%10]
		}
		res += " "
		return res
	}
	if n > 0 && n < 10 {
		res += unidades[n] + " "
	}
	return res
}

func numeroALetras(n int64) string {
	if n == 0 {
		return "cero"
	}
	resultado := ""
	if n >= 1000000 {
		millones := int(n / 1000000)
		if millones == 1 {
			resultado += "un millón "
		} else {
			resultado += convertirBloque(millones) + "millones "
		}
		n %= 1000000
	}
	if n >= 1000 {
		miles := int(n / 1000)
		if miles == 1 {
			resultado += "mil "
		} else {
			resultado += convertirBloque(miles) + "mil "
		}
		n %= 1000
	}
	resultado += convertirBloque(int(n))
	return strings.TrimSpace(resultado)
}

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		queryParam := r.URL.Query().Get("n")
		if queryParam == "" {
			queryParam = "10"
		}

		numero, err := strconv.ParseInt(queryParam, 10, 64)
		w.Header().Set("Content-Type", "text/plain; charset=utf-8")
		
		if err != nil {
			fmt.Fprint(w, "Proporcione un número entero válido en la URL (ej: ?n=10).")
			return
		}

		letras := numeroALetras(numero)
		fmt.Fprint(w, letras)
	})

	fmt.Println("Servidor Go Nativo corriendo en http://localhost:8000")
	http.ListenAndServe(":8000", nil)
}