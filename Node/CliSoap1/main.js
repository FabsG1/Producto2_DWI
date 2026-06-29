const http = require('http');

const server = http.createServer(async (req, res) => {
    // 1. Parsear los parámetros de la URL de forma nativa
    const urlParams = new URL(req.url, `http://${req.headers.host}`);
    let numero = urlParams.searchParams.get('n');
    if (!numero) numero = "10";

    const urlSoap = "https://www.dataaccess.com/webservicesserver/NumberConversion.wso";

    // 2. Construir el sobre SOAP XML
    const soapEnvelope = `<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <NumberToWords xmlns="http://www.dataaccess.com/webservicesserver/">
      <ubiNum>${numero}</ubiNum>
    </NumberToWords>
  </soap:Body>
</soap:Envelope>`;

    try {
        // 3. Despachar la petición POST
        const response = await fetch(urlSoap, {
            method: 'POST',
            headers: {
                'Content-Type': 'text/xml;charset=UTF-8',
                'SOAPAction': '"NumberToWords"'
            },
            body: soapEnvelope
        });

        const xmlResult = await response.text();

        // 4. Extraer el valor interno con expresiones regulares
        const match = xmlResult.match(/<m:NumberToWordsResult>([^<]+)<\/m:NumberToWordsResult>/);
        const resultado = match ? match[1].trim() : "Error al parsear el XML.";

        res.writeHead(200, { 'Content-Type': 'text/plain; charset=utf-8' });
        res.end(resultado);

    } catch (error) {
        res.writeHead(500, { 'Content-Type': 'text/plain; charset=utf-8' });
        res.end(`Error de comunicación: ${error.message}`);
    }
});

server.listen(8000, () => {
    console.log("Servidor Node.js SOAP corriendo en http://localhost:8000");
});