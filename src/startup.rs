use actix_web::{App, HttpServer, web};
use actix_web::dev::Server;
use std::net::TcpListener;

use crate::routes::*;

pub fn run(listener: TcpListener) -> Result<Server, std::io::Error> {
    let addr = listener.local_addr()?;
    let server = HttpServer::new(|| {
        App::new()
            .route("/health_check", web::get().to(health_check))
            .route("/subscriptions", web::post().to(subscribe))
    })
    .listen(listener)?
    .run();

    println!("Server running on {}...", addr);
    
    Ok(server)
}