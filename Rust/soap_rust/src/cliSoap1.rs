use axum::extract::Query;
use std::collections::HashMap;
use reqwest::Client;

pub async fn handler(Query(params): Query<HashMap<String, String>>) -> String {
    let n = params.get("n").map(|s| s.as_str()).unwrap_or("");
    let client = Client::builder().danger_accept_invalid_certs(true).build().unwrap();

    let body = format!(
        r#"<?xml version="1.0" encoding="utf-8"?>
        <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
            <soap:Body>
                <NumberToWords xmlns="http://www.dataaccess.com/webservicesserver/">
                    <ubiNum>{}</ubiNum>
                </NumberToWords>
            </soap:Body>
        </soap:Envelope>"#, n
    );

    let res = client.post("https://www.dataaccess.com/webservicesserver/NumberConversion.wso")
        .header("Content-Type", "text/xml;charset=UTF-8")
        .header("SOAPAction", "NumberToWords")
        .body(body)
        .send().await.unwrap().text().await.unwrap();

    let re = regex::Regex::new(r"<m:NumberToWordsResult>([^<]+)</m:NumberToWordsResult>").unwrap();
    re.captures(&res).map(|cap| cap[1].to_string()).unwrap_or_else(|| "Error".to_string())
}