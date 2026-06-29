import com.sun.net.httpserver.HttpServer;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpExchange;
import java.io.IOException;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class cliSoap1 {

    public static void main(String[] resignation) throws IOException {
        // Levantar servidor en el puerto 8000
        HttpServer server = HttpServer.create(new InetSocketAddress(8000), 0);
        server.createContext("/", new SoapHandler());
        server.setExecutor(null);
        System.out.println("Servidor Java SOAP corriendo en http://localhost:8000");
        server.start();
    }

    static class SoapHandler implements HttpHandler {
        @Override
        public void handle(HttpExchange exchange) throws IOException {
            String query = exchange.getRequestURI().getQuery();
            String numero = getQueryParam(query, "n");
            if (numero == null || numero.isEmpty()) {
                numero = "10";
            }

            String resultadoSoap = consumirServicioSoap(numero);

            exchange.getResponseHeaders().set("Content-Type", "text/plain; charset=utf-8");
            exchange.sendResponseHeaders(200, resultadoSoap.getBytes().length);
            OutputStream os = exchange.getResponseBody();
            os.write(resultadoSoap.getBytes());
            os.close();
        }
    }

    private static String consumirServicioSoap(String numero) {
        String url = "https://www.dataaccess.com/webservicesserver/NumberConversion.wso";
        
        String soapEnvelope = 
            "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n" +
            "<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n" +
            "  <soap:Body>\n" +
            "    <NumberToWords xmlns=\"http://www.dataaccess.com/webservicesserver/\">\n" +
            "      <ubiNum>" + numero + "</ubiNum>\n" +
            "    </NumberToWords>\n" +
            "  </soap:Body>\n" +
            "</soap:Envelope>";

        try {
            HttpClient client = HttpClient.newHttpClient();
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .header("Content-Type", "text/xml;charset=UTF-8")
                    .header("SOAPAction", "\"NumberToWords\"")
                    .POST(HttpRequest.BodyPublishers.ofString(soapEnvelope))
                    .build();

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            String xmlResult = response.body();

            // Extraer el valor de la etiqueta usando expresiones regulares nativas
            Pattern pattern = Pattern.compile("<m:NumberToWordsResult>([^<]+)</m:NumberToWordsResult>");
            Matcher matcher = pattern.matcher(xmlResult);
            if (matcher.find()) {
                return matcher.group(1).trim();
            }
            return "Error al parsear la respuesta XML.";
        } catch (Exception e) {
            return "Error de comunicación SOAP: " + e.getMessage();
        }
    }

    private static String getQueryParam(String query, String key) {
        if (query == null) return null;
        for (String param : query.split("&")) {
            String[] pair = param.split("=");
            if (pair.length > 1 && pair[0].equals(key)) {
                return pair[1];
            }
        }
        return null;
    }
}