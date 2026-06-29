use Mojolicious::Lite -signatures;
use POSIX qw(floor);

my @unidades   = ("", "uno", "dos", "tres", "cuatro", "cinco", "seis", "siete", "ocho", "nueve");
my @decenas    = ("", "diez", "veinte", "treinta", "cuarenta", "cincuenta", "sesenta", "setenta", "ochenta", "noventa");
my @especiales = ("diez", "once", "doce", "trece", "catorce", "quince", "dieciséis", "diecisiete", "dieciocho", "diecinueve");
my @centenas   = ("", "cien", "doscientos", "trescientos", "cuatrocientos", "quinientos", "seiscientos", "setecientos", "ochocientos", "novecientos");

sub convertir_bloque ($n) {
    my $res = "";
    if ($n >= 100) {
        return "cien " if $n == 100;
        if ($n > 100 && $n < 200) {
            $res .= "ciento ";
        } else {
            $res .= $centenas[floor($n / 100)] . " ";
        }
        $n %= 100;
    }
    if ($n >= 10 && $n < 20) {
        $res .= $especiales[$n - 10] . " ";
        return $res;
    } elsif ($n >= 20) {
        return $res . "veinte " if $n == 20;
        return $res . "veinti" . $unidades[$n % 10] . " " if ($n > 20 && $n < 30);
        
        $res .= $decenas[floor($n / 10)];
        $res .= " y " . $unidades[$n % 10] if ($n % 10 != 0);
        $res .= " ";
        return $res;
    }
    if ($n > 0 && $n < 10) {
        $res .= $unidades[$n] . " ";
    }
    return $res;
}

sub numero_a_letras ($n) {
    return "cero" if $n == 0;
    my $resultado = "";

    if ($n >= 1000000) {
        my $millones = floor($n / 1000000);
        if ($millones == 1) {
            $resultado .= "un millón ";
        } else {
            $resultado .= convertir_bloque($millones) . "millones ";
        }
        $n %= 1000000;
    }
    if ($n >= 1000) {
        my $miles = floor($n / 1000);
        if ($miles == 1) {
            $resultado .= "mil ";
        } else {
            $resultado .= convertir_bloque($miles) . "mil ";
        }
        $n %= 1000;
    }
    $resultado .= convertir_bloque($n);
    
    # Trim
    $resultado =~ s/^\s+|\s+$//g;
    return $resultado;
}

get '/' => sub ($c) {
    my $numero_str = $c->param('n') || "10";
    
    # Validar que sea un número
    if ($numero_str =~ /^\d+$/) {
        my $letras = numero_a_letras($numero_str);
        $c->render(text => $letras, format => 'txt');
    } else {
        $c->render(text => "Por favor, proporcione un número entero válido.", format => 'txt');
    }
};

app->start('daemon', '-l', 'http://*:8000');