using System.Text;
using System.Text.RegularExpressions;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/", async (HttpContext context) =>
{
    string queryParam = context.Request.Query["n"].ToString();
    string numero = string.IsNullOrEmpty(queryParam) ?"" : queryParam;

    string url = "https://www.dataaccess.com/webservicesserver/NumberConversion.wso";
    
    // 1. Construir el XML del SOAP Envelope (SOAP 1.1)
    string soapEnvelope = 
        $@"<?xml version=""1.0"" encoding=""utf-8""?>
        <soap:Envelope xmlns:soap=""http://schemas.xmlsoap.org/soap/envelope/"">
          <soap:Body>
            <NumberToWords xmlns=""http://www.dataaccess.com/webservicesserver/"">
              <ubiNum>{numero}</ubiNum>
            </NumberToWords>
          </soap:Body>
        </soap:Envelope>";

    using var client = new HttpClient();
    // Forzar tiempos de espera seguros
    client.Timeout = TimeSpan.FromSeconds(30); 

    var content = new StringContent(soapEnvelope, Encoding.UTF8, "text/xml");

    try
    {
        // 2. Enviar la petición POST al servicio público
        var response = await client.PostAsync(url, content);
        string xmlResult = await response.Content.ReadAsStringAsync();

        // 3. Extraer el resultado usando una expresión regular limpia
        var match = Regex.Match(xmlResult, @"<m:NumberToWordsResult>([^<]+)</m:NumberToWordsResult>");
        
        return match.Success ? match.Groups[1].Value.Trim() : "No se pudo parsear la respuesta SOAP.";
    }
    catch (Exception ex)
    {
        return $"Error de comunicación: {ex.Message}";
    }
});

app.Run();