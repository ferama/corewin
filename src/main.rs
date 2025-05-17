use std::{env, path::PathBuf};

const INIT_PROFILE: &str = include_str!("abw.ps1");

fn main() {
    match env::current_exe() {
        // Ok(exe_path) => println!("Path of this executable is: {}", exe_path.display()),
        Ok(exe_path) => {
            let path_buf = PathBuf::from(exe_path);
            let path = path_buf.parent().unwrap();
            let script = INIT_PROFILE.replace("**PATH**", path.to_str().unwrap());
            print!("{script}");
        }
        Err(e) => panic!("failed to get current exe path: {e}"),
    };
}
