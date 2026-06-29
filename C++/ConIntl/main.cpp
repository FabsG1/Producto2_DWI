// Autor: Fabián García
// Compilar: g++ main.cpp -o conintl.exe -lws2_32 -lcrypt32
// Ejecutar: conintl.exe

#include <iostream>
#include <string>
#include <vector>
#include "../httplib.h"

const std::vector<std::string> unidades = {"", "uno", "dos", "tres", "cuatro", "cinco", "seis", "siete", "ocho", "nueve"};
const std::vector<std::string> decenas = {"", "diez", "veinte", "treinta", "cuarenta", "cincuenta", "sesenta", "setenta", "ochenta", "noventa"};
const std::vector<std::string> especiales = {"diez", "once", "doce", "trece", "catorce", "quince", "dieciséis", "diecisiete", "dieciocho", "diecinueve"};
const std::vector<std::string> centenas = {"", "cien", "doscientos", "trescientos", "cuatrocientos", "quinientos", "seiscientos", "setecientos", "ochocientos", "novecientos"};

std::string convertirBloque(int n) {
    std::string res = "";
    if (n >= 100) {
        if (n == 100) return "cien ";
        if (n > 100 && n < 200) res += "ciento ";
        else res += centenas[n / 100] + " ";
        n %= 100;
    }
    if (n >= 10 && n < 20) {
        res += especiales[n - 10] + " ";
        return res;
    } else if (n >= 20) {
        if (n == 20) return res + "veinte ";
        if (n > 20 && n < 30) return res + "veinti" + unidades[n % 10] + " ";
        res += decenas[n / 10];
        if (n % 10 != 0) res += " y " + unidades[n % 10];
        res += " ";
        return res;
    }
    if (n > 0 && n < 10) {
        res += unidades[n] + " ";
    }
    return res;
}

std::string convertirNumeroALetras(long long n) {
    if (n == 0) return "cero";
    std::string resultado = "";

    if (n >= 1000000) {
        long long millones = n / 1000000;
        if (millones == 1) resultado += "un millón ";
        else resultado += convertirBloque(millones) + "millones ";
        n %= 1000000;
    }
    if (n >= 1000) {
        long long miles = n / 1000;
        if (miles == 1) resultado += "mil ";
        else resultado += convertirBloque(miles) + "mil ";
        n %= 1000;
    }
    resultado += convertirBloque(n);

    if (!resultado.empty() && resultado.back() == ' ') {
        resultado.pop_back();
    }
    return resultado;
}

int main() {
    httplib::Server svr;

    svr.Get("/", [](const httplib::Request& req, httplib::Response& res) {
        std::string queryParam = req.has_param("n") ? req.get_param_value("n") : "10";
        try {
            long long numero = std::stoll(queryParam);
            std::string letras = convertirNumeroALetras(numero);
            res.set_content(letras, "text/plain; charset=utf-8");
        } catch (...) {
            res.set_content("Proporcione un número entero válido.", "text/plain; charset=utf-8");
        }
    });

    std::cout << "Servidor C++ Nativo corriendo en http://localhost:8000" << std::endl;
    svr.listen("localhost", 8000);
    return 0;
}