use clap::{Parser, Subcommand, command};

#[derive(Parser)]
#[command(name = "corewin", version)]
pub struct Cli {
    #[command(subcommand, verbatim_doc_comment)]
    pub command: Option<Commands>,
}
#[derive(Subcommand)]
pub enum Commands {
    /// Generate a PowerShell profile script
    /// Add the following line to your PowerShell profile (edit with `notepad $PROFILE`):
    /// ---
    /// Invoke-Expression (&corewin init | Out-String)
    /// ---
    #[command(name = "init", verbatim_doc_comment)]
    Init,
}
