use Mojolicious::Lite -signatures;
use Mojo::UserAgent;
use Mojo::URL;

app->config(hypnotoad => {listen => ['http://*:8000']});

get '/' => sub ($c) {
    my $numero = $c->param('n') || 10;
    
    # 1. Configuración antibloqueo idéntica al archivo 1
    my $ua = Mojo::UserAgent->new;
    $ua->insecure(1);
    $ua->max_redirects(5);
    $ua->connect_timeout(15);

    # 2. Llamada SOAP (usando IP directa)
    my $soap_envelope = <<"XML";
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body>
<NumberToWords xmlns="http://www.dataaccess.com/webservicesserver/"><ubiNum>$numero</ubiNum></NumberToWords>
</soap:Body></soap:Envelope>
XML

    my $url_soap = 'https://52.7.155.169/webservicesserver/NumberConversion.wso';
    
    my $tx_soap = $ua->post($url_soap => {
        'Content-Type' => 'text/xml;charset=UTF-8',
        'SOAPAction'   => '"NumberToWords"',
        'Host'         => 'www.dataaccess.com'
    } => $soap_envelope);

    my $texto_ingles = "";
    if (my $res = $tx_soap->result) {
        if ($res->body =~ /<m:NumberToWordsResult>([^<]+)<\/m:NumberToWordsResult>/) {
            $texto_ingles = $1;
            $texto_ingles =~ s/^\s+|\s+$//g;
        } else {
            return $c->render(text => "Error parseando SOAP", format => 'txt');
        }
    } else {
        my $err = $tx_soap->error;
        return $c->render(text => "Error red SOAP: " . ($err->{message} || "Desconocido"), format => 'txt');
    }

    # 3. Llamada REST de Traducción (Mojo::URL maneja el %7C automáticamente)
    my $url_rest = Mojo::URL->new('https://api.mymemory.translated.net/get');
    $url_rest->query(q => $texto_ingles, langpair => 'en|es');

    my $tx_rest = $ua->get($url_rest);

    if (my $res = $tx_rest->result) {
        my $json = $res->json;
        my $texto_espanol = lc($json->{responseData}{translatedText});
        $texto_espanol =~ s/^\s+|\s+$//g;
        
        $c->render(text => $texto_espanol, format => 'txt');
    } else {
        $c->render(text => "Error en la API de traducción", format => 'txt');
    }
};

app->start('daemon', '-l', 'http://*:8000');