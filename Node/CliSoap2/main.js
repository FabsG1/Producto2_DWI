const http = require('http');

const server = http.createServer(async (req, res) => {
    const urlParams = new URL(req.url, `http://${req.headers.host}`);
    let numero = urlParams.searchParams.get('n');
    if (!numero) numero = "10";

    try {
        // 1. Obtener cadena en inglés desde el SOAP
        const urlSoap = "https://www.dataaccess.com/webservicesserver/NumberConversion.wso";
        const soapEnvelope = `<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body>
<NumberToWords xmlns="http://www.dataaccess.com/webservicesserver/"><ubiNum>${numero}</ubiNum></NumberToWords>
</soap:Body></soap:Envelope>`;

        const soapResponse = await fetch(urlSoap, {
            method: 'POST',
            headers: { 'Content-Type': 'text/xml;charset=UTF-8' },
            body: soapEnvelope
        });
        const xmlResult = await soapResponse.text();
        const match = xmlResult.match(/<m:NumberToWordsResult>([^<]+)<\/m:NumberToWordsResult>/);
        if (!match) throw new Error("XML no reconocible");
        const textoIngles = match[1].trim();

        // 2. Consumir API REST de traducción (en%7Ces)
        const urlTranslate = `https://api.mymemory.translated.net/get?q=${encodeURIComponent(textoIngles)}&langpair=en%7Ces`;
        const translateResponse = await fetch(urlTranslate);
        const jsonResult = await translateResponse.json();

        // 3. Extraer el texto traducido del objeto JSON plano
        const textoEspanol = jsonResult.responseData.translatedText.toLowerCase().trim();

        res.writeHead(200, { 'Content-Type': 'text/plain; charset=utf-8' });
        res.end(textoEspanol);

    } catch (error) {
        res.writeHead(500, { 'Content-Type': 'text/plain; charset=utf-8' });
        res.end(`Fallo en procesamiento: ${error.message}`);
    }
});

server.listen(8000, () => {
    console.log("Servidor Node.js Traductor corriendo en http://localhost:8000");
});