#include <iostream>
#include <string>
#include <regex>
#include <curl/curl.h>
#include "../httplib.h"

// Función callback requerida por cURL para guardar los fragmentos de la respuesta HTTP
size_t WriteCallback(void* contents, size_t size, size_t nmemb, void* userp) {
    ((std::string*)userp)->append((char*)contents, size * nmemb);
    return size * nmemb;
}

std::string consumirServicioSoap(const std::string& numero) {
    CURL* curl = curl_easy_init();
    std::string responseBuffer;

    if (curl) {
        std::string url = "https://www.dataaccess.com/webservicesserver/NumberConversion.wso";
        
        std::string soapEnvelope = 
            "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
            "<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
            "  <soap:Body>\n"
            "    <NumberToWords xmlns=\"http://www.dataaccess.com/webservicesserver/\">\n"
            "      <ubiNum>" + numero + "</ubiNum>\n"
            "    </NumberToWords>\n"
            "  </soap:Body>\n"
            "</soap:Envelope>";

        struct curl_slist* headers = NULL;
        headers = curl_slist_append(headers, "Content-Type: text/xml;charset=UTF-8");
        headers = curl_slist_append(headers, "SOAPAction: \"NumberToWords\"");

        curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
        curl_easy_setopt(curl, CURLOPT_POSTFIELDS, soapEnvelope.c_str());
        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &responseBuffer);
        
        // Evadir bloqueos de infraestructura/certificados locales interrumpiendo la cadena
        curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);

        curl_easy_perform(curl);
        curl_slist_free_all(headers);
        curl_easy_cleanup(curl);
    }

    // Extracción limpia de la etiqueta de resultado usando expresiones regulares
    std::regex rgx("<m:NumberToWordsResult>([^<]+)</m:NumberToWordsResult>");
    std::smatch match;
    if (std::regex_search(responseBuffer, match, rgx)) {
        return match[1].str();
    }
    return "Error al parsear la respuesta SOAP.";
}

int main() {
    httplib::Server svr;

    svr.Get("/", [](const httplib::Request& req, httplib::Response& res) {
        std::string numero = req.has_param("n") ? req.get_param_value("n") : "10";
        std::string resultado = consumirServicioSoap(numero);
        res.set_content(resultado, "text/plain; charset=utf-8");
    });

    std::cout << "Servidor C++ SOAP corriendo en http://localhost:8000" << std::endl;
    svr.listen("localhost", 8000);
    return 0;
}