const http = require('http');

const unidades = ["", "uno", "dos", "tres", "cuatro", "cinco", "seis", "siete", "ocho", "nueve"];
const decenas = ["", "diez", "veinte", "treinta", "cuarenta", "cincuenta", "sesenta", "setenta", "ochenta", "noventa"];
const especiales = ["diez", "once", "doce", "trece", "catorce", "quince", "dieciséis", "diecisiete", "dieciocho", "diecinueve"];
const centenas = ["", "cien", "doscientos", "trescientos", "cuatrocientos", "quinientos", "seiscientos", "setecientos", "ochocientos", "novecientos"];

function convertirBloque(n) {
    let res = "";
    if (n >= 100) {
        if (n === 100) return "cien ";
        if (n > 100 && n < 200) res += "ciento ";
        else res += centenas[Math.floor(n / 100)] + " ";
        n %= 100;
    }
    if (n >= 10 && n < 20) {
        res += especiales[n - 10] + " ";
        return res;
    } else if (n >= 20) {
        if (n === 20) return res + "veinte ";
        if (n > 20 && n < 30) return res + "veinti" + unidades[n % 10] + " ";
        res += decenas[Math.floor(n / 10)];
        if (n % 10 !== 0) res += " y " + unidades[n % 10];
        res += " ";
        return res;
    }
    if (n > 0 && n < 10) {
        res += unidades[n] + " ";
    }
    return res;
}

function numeroALetras(n) {
    if (n === 0) return "cero";
    let resultado = "";

    if (n >= 1000000) {
        const millones = Math.floor(n / 1000000);
        if (millones === 1) resultado += "un millón ";
        else resultado += convertirBloque(millones) + "millones ";
        n %= 1000000;
    }
    if (n >= 1000) {
        const miles = Math.floor(n / 1000);
        if (miles === 1) resultado += "mil ";
        else resultado += convertirBloque(miles) + "mil ";
        n %= 1000;
    }
    resultado += convertirBloque(n);
    return resultado.trim();
}

const server = http.createServer((req, res) => {
    const urlParams = new URL(req.url, `http://${req.headers.host}`);
    let queryParam = urlParams.searchParams.get('n');
    if (!queryParam) queryParam = "10";

    const numero = parseInt(queryParam, 10);
    res.writeHead(200, { 'Content-Type': 'text/plain; charset=utf-8' });

    if (isNaN(numero)) {
        res.end("Por favor, proporcione un número entero válido.");
    } else {
        res.end(numeroALetras(numero));
    }
});

server.listen(8000, () => {
    console.log("Servidor Node.js Nativo corriendo en http://localhost:8000");
});