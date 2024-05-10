use std::env;

fn main() {
    hbb_common::gen_version();
    // Récupère la version du crate principal
    let version = env::var("CARGO_PKG_VERSION").unwrap();

    // Passe la version à l'environnement de compilation
    println!("cargo:rustc-env=MAIN_PKG_VERSION={}", version);
}