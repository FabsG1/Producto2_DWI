use axum::extract::Query;
use std::collections::HashMap;

pub async fn handler(Query(params): Query<HashMap<String, String>>) -> String {
    let n: u64 = params.get("n")
        .and_then(|s| s.parse().ok())
        .unwrap_or(10);

    format!("{}", convertir_a_letras(n))
}

fn convertir_bloque(n: u64) -> String {
    let unidades = ["", "uno", "dos", "tres", "cuatro", "cinco", "seis", "siete", "ocho", "nueve"];
    let decenas = ["", "diez", "veinte", "treinta", "cuarenta", "cincuenta", "sesenta", "setenta", "ochenta", "noventa"];
    let especiales = ["diez", "once", "doce", "trece", "catorce", "quince", "dieciséis", "diecisiete", "dieciocho", "diecinueve"];
    let centenas = ["", "cien", "doscientos", "trescientos", "cuatrocientos", "quinientos", "seiscientos", "setecientos", "ochocientos", "novecientos"];

    let mut res = String::new();
    let mut num = n;

    if num >= 100 {
        if num == 100 { return "cien ".to_string(); }
        if num > 100 && num < 200 { res.push_str("ciento "); }
        else { res.push_str(centenas[(num / 100) as usize]); res.push(' '); }
        num %= 100;
    }

    if num >= 10 && num < 20 {
        res.push_str(especiales[(num - 10) as usize]);
        res.push(' ');
    } else if num >= 20 {
        if num == 20 { res.push_str("veinte "); }
        else if num > 20 && num < 30 { res.push_str(&format!("veinti{} ", unidades[(num % 10) as usize])); }
        else {
            res.push_str(decenas[(num / 10) as usize]);
            if num % 10 != 0 { res.push_str(&format!(" y {}", unidades[(num % 10) as usize])); }
            res.push(' ');
        }
    } else if num > 0 {
        res.push_str(unidades[num as usize]);
        res.push(' ');
    }
    res
}

fn convertir_a_letras(n: u64) -> String {
    if n == 0 { return "cero".to_string(); }
    let mut resultado = String::new();
    let mut num = n;

    if num >= 1_000_000 {
        let millones = num / 1_000_000;
        resultado.push_str(if millones == 1 { "un millón ".to_string() } else { format!("{}millones ", convertir_bloque(millones)) }.as_str());
        num %= 1_000_000;
    }

    if num >= 1_000 {
        let miles = num / 1_000;
        resultado.push_str(if miles == 1 { "mil ".to_string() } else { format!("{}mil ", convertir_bloque(miles)) }.as_str());
        num %= 1_000;
    }

    resultado.push_str(&convertir_bloque(num));
    resultado.trim().to_string()
}