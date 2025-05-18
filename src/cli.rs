use clap::{Parser, Subcommand, command};

#[derive(Parser)]
#[command(name = "ABW", version)]
pub struct Cli {
    #[command(subcommand)]
    pub command: Option<Commands>,
}
#[derive(Subcommand)]
pub enum Commands {
    /// Generate a PowerShell profile script
    #[command(name = "init")]
    Init,
}
