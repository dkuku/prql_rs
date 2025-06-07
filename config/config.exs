import Config

config :rustler_precompiled,
  otp_app: :prql_rs,
  targets: [
    # Linux
    "x86_64-unknown-linux-gnu",
    "aarch64-unknown-linux-gnu",
    # macOS
    "x86_64-apple-darwin",
    "aarch64-apple-darwin",
    # Windows
    "x86_64-pc-windows-gnu",
    "x86_64-pc-windows-msvc"
  ]
