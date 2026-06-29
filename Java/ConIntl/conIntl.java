import com.sun.net.httpserver.HttpServer;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpExchange;
import java.io.IOException;
import java.io.OutputStream;
import java.net.InetSocketAddress;

public class conIntl {

    private static final String[] unidades = {"", "uno", "dos", "tres", "cuatro", "cinco", "seis", "siete", "ocho", "nueve"};
    private static final String[] decenas = {"", "diez", "veinte", "treinta", "cuarenta", "cincuenta", "sesenta", "setenta", "ochenta", "noventa"};
    private static final String[] especiales = {"diez", "once", "doce", "trece", "catorce", "quince", "dieciséis", "diecisiete", "dieciocho", "diecinueve"};
    private static final String[] centenas = {"", "cien", "doscientos", "trescientos", "cuatrocientos", "quinientos", "seiscientos", "setecientos", "ochocientos", "novecientos"};

    public static void main(String[] args) throws IOException {
        HttpServer server = HttpServer.create(new InetSocketAddress(8000), 0);
        server.createContext("/", new NativeHandler());
        server.setExecutor(null);
        System.out.println("Servidor Java Nativo corriendo en http://localhost:8000");
        server.start();
    }

    static class NativeHandler implements HttpHandler {
        @Override
        public void handle(HttpExchange exchange) throws IOException {
            String query = exchange.getRequestURI().getQuery();
            String queryParam = getQueryParam(query, "n");
            if (queryParam == null || queryParam.isEmpty()) {
                queryParam = "10";
            }

            String responseText;
            try {
                long numero = Long.parseLong(queryParam);
                responseText = numeroALetras(numero);
            } catch (NumberFormatException e) {
                responseText = "Proporcione un número entero válido.";
            }

            exchange.getResponseHeaders().set("Content-Type", "text/plain; charset=utf-8");
            byte[] responseBytes = responseText.getBytes(java.nio.charset.StandardCharsets.UTF_8);
            exchange.sendResponseHeaders(200, responseBytes.length);
            OutputStream os = exchange.getResponseBody();
            os.write(responseBytes);
            os.close();
        }
    }

    private static String convertirBloque(int n) {
        StringBuilder res = new StringBuilder();
        if (n >= 100) {
            if (n == 100) return "cien ";
            if (n > 100 && n < 200) res.append("ciento ");
            else res.append(centenas[n / 100]).append(" ");
            n %= 100;
        }
        if (n >= 10 && n < 20) {
            res.append(especiales[n - 10]).append(" ");
            return res.toString();
        } else if (n >= 20) {
            if (n == 20) return res.append("veinte ").toString();
            if (n > 20 && n < 30) return res.append("veinti").append(unidades[n % 10]).append(" ").toString();
            res.append(decenas[n / 10]);
            if (n % 10 != 0) res.append(" y ").append(unidades[n % 10]);
            res.append(" ");
            return res.toString();
        }
        if (n > 0 && n < 10) {
            res.append(unidades[n]).append(" ");
        }
        return res.toString();
    }

    private static String numeroALetras(long n) {
        if (n == 0) return "cero";
        StringBuilder resultado = new StringBuilder();

        if (n >= 1000000) {
            int millones = (int) (n / 1000000);
            if (millones == 1) resultado.append("un millón ");
            else resultado.append(convertirBloque(millones)).append("millones ");
            n %= 1000000;
        }
        if (n >= 1000) {
            int miles = (int) (n / 1000);
            if (miles == 1) resultado.append("mil ");
            else resultado.append(convertirBloque(miles)).append("mil ");
            n %= 1000;
        }
        resultado.append(convertirBloque((int) n));
        return resultado.toString().trim();
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