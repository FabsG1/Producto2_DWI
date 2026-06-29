import com.sun.net.httpserver.HttpServer;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpExchange;
import java.io.IOException;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class cliSoap2 {

    public static void main(String[] args) throws IOException {
        HttpServer server = HttpServer.create(new InetSocketAddress(8000), 0);
        server.createContext("/", new TranslateHandler());
        server.setExecutor(null);
        System.out.println("Servidor Java Traductor corriendo en http://localhost:8000");
        server.start();
    }

    static class TranslateHandler implements HttpHandler {
        @Override
        public void handle(HttpExchange exchange) throws IOException {
            String query = exchange.getRequestURI().getQuery();
            String numero = getQueryParam(query, "n");
            if (numero == null || numero.isEmpty()) {
                numero = "10";
            }

            String textoIngles = obtenerInglesSoap(numero);
            String textoEspanol = traducirEspanol(textoIngles);

            exchange.getResponseHeaders().set("Content-Type", "text/plain; charset=utf-8");
            exchange.sendResponseHeaders(200, textoEspanol.getBytes().length);
            OutputStream os = exchange.getResponseBody();
            os.write(textoEspanol.getBytes());
            os.close();
        }
    }

    private static String obtenerInglesSoap(String numero) {
        String url = "https://www.dataaccess.com/webservicesserver/NumberConversion.wso";
        String soapEnvelope = 
            "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n" +
            "<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n" +
            "  <soap:Body><NumberToWords xmlns=\"http://www.dataaccess.com/webservicesserver/\">" +
            "<ubiNum>" + numero + "</ubiNum></NumberToWords></soap:Body></soap:Envelope>";

        try {
            HttpClient client = HttpClient.newHttpClient();
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .header("Content-Type", "text/xml;charset=UTF-8")
                    .POST(HttpRequest.BodyPublishers.ofString(soapEnvelope))
                    .build();
            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            Matcher matcher = Pattern.compile("<m:NumberToWordsResult>([^<]+)</m:NumberToWordsResult>").matcher(response.body());
            return matcher.find() ? matcher.group(1).trim() : "";
        } catch (Exception e) {
            return "Error de comunicación SOAP: " + e.getMessage();
        }
    }

    private static String traducirEspanol(String texto) {
        try {
            HttpClient client = HttpClient.newHttpClient();
            String apiURL = "https://api.mymemory.translated.net/get?q=" + URLEncoder.encode(texto, StandardCharsets.UTF_8) + "&langpair=en%7Ces";
            
            HttpRequest request = HttpRequest.newBuilder().uri(URI.create(apiURL)).GET().build();
            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            
            // Extraer el campo translatedText de la respuesta JSON
            Matcher matcher = Pattern.compile("\"translatedText\":\"([^\"]+)\"").matcher(response.body());
            if (matcher.find()) {
                return matcher.group(1).toLowerCase().trim();
            }
            return "Error al traducir.";
        } catch (Exception e) {
            return "Fallo en traducción: " + e.getMessage();
        }
    }

    private static String getQueryParam(String query, String key) {
        if (query == null) return null;
        for (String param : query.split("&")) {
            String[] pair = param.split("=");
            if (pair.length > 1 && pair[0].equals(key)) return pair[1];
        }
        return null;
    }
}