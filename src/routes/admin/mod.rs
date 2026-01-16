//! src/routes/admin/mod.rs

mod dashboard;
mod logout;
mod newsletter;
mod password;

pub use dashboard::admin_dashboard;
pub use logout::log_out;
pub use newsletter::{publish_newsletter, publish_newsletter_form};
pub use password::*;
