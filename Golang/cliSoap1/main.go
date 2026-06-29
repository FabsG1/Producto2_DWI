package main

import (
	"bytes"
	"crypto/tls"
	"fmt"
	"io"
	"net/http"
	"regexp"
	"strings"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		numero := r.URL.Query().Get("n")
		if numero == "" {
			numero = "10"
		}

		// 1. Configurar cliente HTTP omitiendo la verificación SSL (Antibloqueo)
		tr := &http.Transport{
			TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
		}
		client := &http.Client{Transport: tr}

		// 2. Construir el sobre SOAP
		soapEnvelope := fmt.Sprintf(`<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <NumberToWords xmlns="http://www.dataaccess.com/webservicesserver/">
      <ubiNum>%s</ubiNum>
    </NumberToWords>
  </soap:Body>
</soap:Envelope>`, numero)

		req, err := http.NewRequest("POST", "https://www.dataaccess.com/webservicesserver/NumberConversion.wso", bytes.NewBuffer([]byte(soapEnvelope)))
		if err != nil {
			http.Error(w, "Error creando petición", http.StatusInternalServerError)
			return
		}
		req.Header.Set("Content-Type", "text/xml;charset=UTF-8")
		req.Header.Set("SOAPAction", `"NumberToWords"`)

		// 3. Ejecutar la petición
		resp, err := client.Do(req)
		if err != nil {
			http.Error(w, "Error de red: "+err.Error(), http.StatusBadGateway)
			return
		}
		defer resp.Body.Close()

		body, _ := io.ReadAll(resp.Body)
		xmlResult := string(body)

		// 4. Extraer el resultado usando expresiones regulares
		re := regexp.MustCompile(`<m:NumberToWordsResult>([^<]+)</m:NumberToWordsResult>`)
		match := re.FindStringSubmatch(xmlResult)

		if len(match) > 1 {
			w.Header().Set("Content-Type", "text/plain; charset=utf-8")
			fmt.Fprint(w, strings.TrimSpace(match[1]))
		} else {
			fmt.Fprint(w, "Error al parsear el XML de respuesta.")
		}
	})

	fmt.Println("Servidor Go SOAP corriendo en http://localhost:8000")
	http.ListenAndServe(":8000", nil)
}