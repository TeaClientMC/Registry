fn main() {
    // Get the current year at compile time
    let current_year = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map(|d| 1970 + d.as_secs() / 31_557_600) // Rough calendar year calculation
        .unwrap_or(2026);

    println!("cargo:rustc-env=CURRENT_YEAR={}", current_year);
}
