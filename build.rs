use std::{env, fs::File, path::PathBuf};

fn main() {
    hbb_common::gen_version();
    // Récupère la version du crate principal
    let version = env::var("CARGO_PKG_VERSION").unwrap();

    // Construit le chemin du fichier dans le répertoire temporaire
    let tmp_dir = env::var("TMP").or_else(|_| env::var("TEMP")).or_else(|_| env::var("TMPDIR")).unwrap_or_else(|_| "/tmp".to_string());
    let mut path = PathBuf::from(tmp_dir);
    path.push("version.txt");

    // Écrit la version dans le fichier
    let mut file = File::create(&path).unwrap();
    writeln!(file, "{}", version).unwrap();

    // Passe la version à l'environnement de compilation
    println!("cargo:rustc-env=MAIN_PKG_VERSION={}", version);
}