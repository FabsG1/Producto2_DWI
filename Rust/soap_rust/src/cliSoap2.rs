use axum::extract::Query;
use std::collections::HashMap;
use reqwest::Client;

pub async fn handler(Query(params): Query<HashMap<String, String>>) -> String {
    let n = params.get("n").map(|s| s.as_str()).unwrap_or("");
    let client = Client::builder().danger_accept_invalid_certs(true).build().unwrap();

    // 1. Obtener inglés
    let soap_body = format!(r#"<soap:Envelope ...><soap:Body><NumberToWords xmlns="..."><ubiNum>{}</ubiNum></NumberToWords></soap:Body></soap:Envelope>"#, n);
    let soap_res = client.post("https://www.dataaccess.com/webservicesserver/NumberConversion.wso")
        .header("Content-Type", "text/xml;charset=UTF-8").body(soap_body).send().await.unwrap().text().await.unwrap();
    
    let re = regex::Regex::new(r"<m:NumberToWordsResult>([^<]+)</m:NumberToWordsResult>").unwrap();
    let ingles = re.captures(&soap_res).map(|cap| cap[1].to_string()).unwrap_or("error".to_string());

    // 2. Traducir
    let url = format!("https://api.mymemory.translated.net/get?q={}&langpair=en%7Ces", urlencoding::encode(&ingles));
    let json: serde_json::Value = client.get(url).send().await.unwrap().json().await.unwrap();
    json["responseData"]["translatedText"].as_str().unwrap_or("error").to_lowercase()
}