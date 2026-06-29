mod cliSoap1;   // Importa cliSoap1.rs
mod cliSoap2;    // Importa cliSoap2.rs
mod conIntl;     // Importa conIntl.rs

use axum::{routing::get, Router};

#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/soap", get(cliSoap1::handler))
        .route("/translate", get(cliSoap2::handler))
        .route("/native", get(conIntl::handler));
        
    let listener = tokio::net::TcpListener::bind("127.0.0.1:8000").await.unwrap();
    println!("Servidor Rust modular activo en http://localhost:8000");
    axum::serve(listener, app).await.unwrap();
}