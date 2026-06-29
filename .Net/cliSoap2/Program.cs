using System.Text;
using System.Text.Json;
using System.Text.RegularExpressions;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/", async (HttpContext context) =>
{
    string queryParam = context.Request.Query["n"].ToString();
    string numero = string.IsNullOrEmpty(queryParam) ?"" : queryParam;

    using var client = new HttpClient();
    client.Timeout = TimeSpan.FromSeconds(30);

    try
    {
        // 1. Obtener el número en inglés desde el SOAP
        string soapUrl = "https://www.dataaccess.com/webservicesserver/NumberConversion.wso";
        string soapEnvelope = 
            $@"<?xml version=""1.0"" encoding=""utf-8""?>
            <soap:Envelope xmlns:soap=""http://schemas.xmlsoap.org/soap/envelope/"">
              <soap:Body>
                <NumberToWords xmlns=""http://www.dataaccess.com/webservicesserver/"">
                  <ubiNum>{numero}</ubiNum>
                </NumberToWords>
              </soap:Body>
            </soap:Envelope>";

        var soapContent = new StringContent(soapEnvelope, Encoding.UTF8, "text/xml");
        var soapResponse = await client.PostAsync(soapUrl, soapContent);
        string xmlResult = await soapResponse.Content.ReadAsStringAsync();
        var match = Regex.Match(xmlResult, @"<m:NumberToWordsResult>([^<]+)</m:NumberToWordsResult>");
        
        if (!match.Success) return "Error al obtener el número en inglés.";
        string textoIngles = match.Groups[1].Value.Trim();

        // 2. Consumir API de traducción (English -> Spanish)
        string translateUrl = $"https://api.mymemory.translated.net/get?q={Uri.EscapeDataString(textoIngles)}&langpair=en|es";
        string jsonResult = await client.GetStringAsync(translateUrl);

        // 3. Parsear el JSON de respuesta
        using var jsonDoc = JsonDocument.Parse(jsonResult);
        string textoEspanol = jsonDoc.RootElement.GetProperty("responseData").GetProperty("translatedText").GetString();

        return textoEspanol?.ToLower().Trim() ?? "Error en la traducción.";
    }
    catch (Exception ex)
    {
        return $"Fallo en la ejecución: {ex.Message}";
    }
});

app.Run();