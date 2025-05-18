use clap::CommandFactory;
use clap::Parser;
use std::{env, path::PathBuf};

mod cli;
use cli::*;

const INIT_PROFILE: &str = include_str!("abw.ps1");

fn init() {
    match env::current_exe() {
        Ok(exe_path) => {
            let path_buf = PathBuf::from(exe_path);
            let path = path_buf.parent().unwrap();
            let script = INIT_PROFILE.replace("**PATH**", path.to_str().unwrap());
            print!("{script}");
        }
        Err(e) => panic!("failed to get current exe path: {e}"),
    };
}

fn main() {
    let cli = Cli::parse();

    match cli.command {
        Some(Commands::Init) => init(),
        None => {
            let help = Cli::command().render_help();
            println!("{}", help.ansi());
            std::process::exit(0);
        }
    }
}
