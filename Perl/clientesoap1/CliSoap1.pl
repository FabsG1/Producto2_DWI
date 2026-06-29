# Autor: Fabián García
# Ejecutar con: perl clisoap1.pl
# Probar en: http://localhost:8016/?n=10

use Mojolicious::Lite -signatures;
use Mojo::UserAgent;

app->config(hypnotoad => {listen => ['http://*:8000']});

get '/' => sub ($c) {
    my $numero = $c->param('n') || 10;
    
    # 1. Configuración de cliente "Modo Tanque" para evadir firewalls/DNS
    my $ua = Mojo::UserAgent->new;
    $ua->insecure(1);           # Evadir bloqueos de certificados locales
    $ua->max_redirects(5);      # Seguir cambios de ruta (301/302)
    $ua->connect_timeout(15);   # Darle más margen de respiración al socket

    # 2. Sobre XML
    my $soap_envelope = <<"XML";
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <NumberToWords xmlns="http://www.dataaccess.com/webservicesserver/">
      <ubiNum>$numero</ubiNum>
    </NumberToWords>
  </soap:Body>
</soap:Envelope>
XML

    # 3. Disparar directamente a la IP IPv4 para evadir el agujero negro IPv6 de Windows
    my $url = 'https://52.7.155.169/webservicesserver/NumberConversion.wso';
    
    my $tx = $ua->post($url => {
        'Content-Type' => 'text/xml;charset=UTF-8',
        'SOAPAction'   => '"NumberToWords"',
        'Host'         => 'www.dataaccess.com' # Le decimos al servidor quiénes somos
    } => $soap_envelope);

    # 4. Procesar Respuesta
    if (my $res = $tx->result) {
        if ($res->body =~ /<m:NumberToWordsResult>([^<]+)<\/m:NumberToWordsResult>/) {
            my $resultado = $1;
            $resultado =~ s/^\s+|\s+$//g; 
            
            $c->render(text => $resultado, format => 'txt');
        } else {
            $c->render(text => "Error al parsear el XML.", format => 'txt');
        }
    } else {
        my $err = $tx->error;
        $c->render(text => "Fallo de red: " . ($err->{message} || "Desconocido"), format => 'txt');
    }
};

app->start('daemon', '-l', 'http://*:8000');