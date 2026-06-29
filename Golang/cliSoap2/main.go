package main

import (
	"bytes"
	"crypto/tls"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"regexp"
	"strings"
)

// Estructura para mapear el JSON de respuesta de la API de traducción
type TranslationResponse struct {
	ResponseData struct {
		TranslatedText string `json:"translatedText"`
	} `json:"responseData"`
}

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		numero := r.URL.Query().Get("n")
		if numero == "" {
			numero = "10"
		}

		tr := &http.Transport{TLSClientConfig: &tls.Config{InsecureSkipVerify: true}}
		client := &http.Client{Transport: tr}

		// 1. Petición SOAP (Inglés)
		soapEnvelope := fmt.Sprintf(`<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body>
<NumberToWords xmlns="http://www.dataaccess.com/webservicesserver/"><ubiNum>%s</ubiNum></NumberToWords>
</soap:Body></soap:Envelope>`, numero)

		reqSOAP, _ := http.NewRequest("POST", "https://www.dataaccess.com/webservicesserver/NumberConversion.wso", bytes.NewBuffer([]byte(soapEnvelope)))
		reqSOAP.Header.Set("Content-Type", "text/xml;charset=UTF-8")
		
		respSOAP, err := client.Do(reqSOAP)
		if err != nil {
			http.Error(w, "Error de red SOAP: "+err.Error(), http.StatusBadGateway)
			return
		}
		defer respSOAP.Body.Close()

		bodySOAP, _ := io.ReadAll(respSOAP.Body)
		re := regexp.MustCompile(`<m:NumberToWordsResult>([^<]+)</m:NumberToWordsResult>`)
		match := re.FindStringSubmatch(string(bodySOAP))
		
		if len(match) < 2 {
			http.Error(w, "Error parseando SOAP", http.StatusInternalServerError)
			return
		}
		textoIngles := strings.TrimSpace(match[1])

		// 2. Petición REST (Traducción a Español)
		apiURL := fmt.Sprintf("https://api.mymemory.translated.net/get?q=%s&langpair=en|es", url.QueryEscape(textoIngles))
		reqREST, _ := http.NewRequest("GET", apiURL, nil)
		
		respREST, err := client.Do(reqREST)
		if err != nil {
			http.Error(w, "Error de red REST: "+err.Error(), http.StatusBadGateway)
			return
		}
		defer respREST.Body.Close()

		// 3. Parsear el JSON
		var translation TranslationResponse
		if err := json.NewDecoder(respREST.Body).Decode(&translation); err != nil {
			http.Error(w, "Error parseando JSON", http.StatusInternalServerError)
			return
		}

		w.Header().Set("Content-Type", "text/plain; charset=utf-8")
		fmt.Fprint(w, strings.ToLower(translation.ResponseData.TranslatedText))
	})

	fmt.Println("Servidor Go Traductor corriendo en http://localhost:8000")
	http.ListenAndServe(":8000", nil)
}