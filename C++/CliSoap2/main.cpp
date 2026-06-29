// Autor: Fabián García
// Compilar: g++ main.cpp -o clisoap2.exe -lcurl -lws2_32 -lcrypt32
// Ejecutar: clisoap2.exe

#include <iostream>
#include <string>
#include <regex>
#include <curl/curl.h>
#include "../httplib.h"

size_t WriteCallback(void* contents, size_t size, size_t nmemb, void* userp) {
    ((std::string*)userp)->append((char*)contents, size * nmemb);
    return size * nmemb;
}

std::string obtenerTraduccion(const std::string& textoIngles) {
    CURL* curl = curl_easy_init();
    std::string responseBuffer;

    if (curl) {
        // Escapar caracteres del texto para la URL de la API
        char* escapedTexto = curl_easy_escape(curl, textoIngles.c_str(), textoIngles.length());
        std::string query(escapedTexto);
        curl_free(escapedTexto);

        std::string url = "https://api.mymemory.translated.net/get?q=" + query + "&langpair=en|es";

        curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &responseBuffer);
        curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);

        curl_easy_perform(curl);
        curl_easy_cleanup(curl);
    }

    // Buscar el campo traducido dentro de la cadena JSON devuelta
    std::regex rgx("\"translatedText\":\"([^\"]+)\"");
    std::smatch match;
    if (std::regex_search(responseBuffer, match, rgx)) {
        return match[1].str();
    }
    return "Error al traducir.";
}

// Reutiliza la función del Archivo 7 para consumir el SOAP
std::string consumirSoap(const std::string& numero) {
    CURL* curl = curl_easy_init();
    std::string buffer;
    if (curl) {
        std::string url = "https://www.dataaccess.com/webservicesserver/NumberConversion.wso";
        std::string envelope = 
            "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
            "<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
            "  <soap:Body><NumberToWords xmlns=\"http://www.dataaccess.com/webservicesserver/\">"
            "<ubiNum>" + numero + "</ubiNum></NumberToWords></soap:Body></soap:Envelope>";
        struct curl_slist* headers = NULL;
        headers = curl_slist_append(headers, "Content-Type: text/xml;charset=UTF-8");
        curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
        curl_easy_setopt(curl, CURLOPT_POSTFIELDS, envelope.c_str());
        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &buffer);
        curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
        curl_easy_perform(curl);
        curl_slist_free_all(headers);
        curl_easy_cleanup(curl);
    }
    std::regex rgx("<m:NumberToWordsResult>([^<]+)</m:NumberToWordsResult>");
    std::smatch match;
    return std::regex_search(buffer, match, rgx) ? match[1].str() : "";
}

int main() {
    httplib::Server svr;

    svr.Get("/", [](const httplib::Request& req, httplib::Response& res) {
        std::string numero = req.has_param("n") ? req.get_param_value("n") : "10";
        std::string ingles = consumirSoap(numero);
        std::string resultadoEsp = obtenerTraduccion(ingles);
        res.set_content(resultadoEsp, "text/plain; charset=utf-8");
    });

    std::cout << "Servidor C++ Traductor corriendo en http://localhost:8000" << std::endl;
    svr.listen("localhost", 8000);
    return 0;
}