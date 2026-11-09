class AppleMusicDiscordRpc < Formula
  desc "Discord Rich Presence client for the macOS Apple Music app (part-avocado fork)"
  homepage "https://github.com/partavocado-forks/apple-music-discord-rpc"
  url "https://github.com/partavocado-forks/apple-music-discord-rpc/releases/download/v2026.11.09-1/apple-music-discord-rpc-2026.11.09-1.tar.gz"
  version "2026.11.09-1"
  sha256 "566d0bc71fab35126ca665a5ed43d18c9f3a16924fb2a059762f903d05116428"
  license "MIT"
  head "https://github.com/partavocado-forks/apple-music-discord-rpc.git", branch: "main"

  depends_on "deno"
  depends_on :macos

  def install
    libexec.install "music-rpc.ts", "discord.ts", "jxa.ts"

    (bin/"apple-music-discord-rpc").write <<~SH
      #!/bin/sh
      exec "#{Formula["deno"].opt_bin}/deno" run \\
        --allow-env --allow-run --allow-net --allow-read --allow-write \\
        --allow-ffi --allow-import --unstable-kv \\
        "#{opt_libexec}/music-rpc.ts" "$@"
    SH
    chmod 0755, bin/"apple-music-discord-rpc"
  end

  def post_install
    (var/"apple-music-discord-rpc").mkpath
  end

  service do
    run opt_bin/"apple-music-discord-rpc"
    keep_alive true
    environment_variables PATH: std_service_path_env
    working_dir var/"apple-music-discord-rpc"
    log_path var/"apple-music-discord-rpc/music-rpc.log"
    error_log_path var/"apple-music-discord-rpc/music-rpc.log"
  end

  test do
    assert_predicate libexec/"music-rpc.ts", :exist?
    assert_predicate bin/"apple-music-discord-rpc", :executable?
  end
end
