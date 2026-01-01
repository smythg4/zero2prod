use crate::routes::{health_check, subscribe};
use actix_web::{App, HttpServer, web};
use actix_web::dev::Server;
use std::net::TcpListener;
use sqlx::PgPool;

pub fn run(listener: TcpListener, connection_pool: PgPool) -> Result<Server, std::io::Error> {
    let addr = listener.local_addr()?;

    let db_pool = web::Data::new(connection_pool); // wraps it in an Arc
    let server = HttpServer::new(move || {
        App::new()
            .route("/health_check", web::get().to(health_check))
            .route("/subscriptions", web::post().to(subscribe))
            .app_data(db_pool.clone())
    })
    .listen(listener)?
    .run();

    println!("Server running on {}...", addr);
    
    Ok(server)
}