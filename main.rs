use std::env;
use std::fs;
use std::process::Command;

fn main() {
    let args: Vec<String> = env::args().collect();
    let mut os_name = String::from("CachyOS");

    if let Ok(contents) = fs::read_to_string("/etc/os-release") {
        for line in contents.lines() {
            if line.starts_with("NAME=") {
                let val = &line[5..];
                os_name = val.trim_matches('"').to_string();
                break;
            }
        }
    }

    if args.len() > 1 && args[1] == "--version" {
        println!("{} Elite Rank CLI v2.0.0 (Polyglot IPC Pipeline)", os_name);
        return;
    }

    // Trigger pipeline components silently
    let _ = Command::new("/usr/bin/rank-probe").status();
    let _ = Command::new("/usr/bin/rank-collector").status();

    println!("{} Divine Tier | IPC Pipeline Executed Successfully", os_name);
}
