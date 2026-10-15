class AppleMusicDiscordRpc < Formula
  desc "Discord Rich Presence client for the macOS Apple Music app (part-avocado fork)"
  homepage "https://github.com/part-avocado/apple-music-discord-rpc"
  url "https://github.com/part-avocado/apple-music-discord-rpc/archive/3640603a73198b27a4d0ae5d9d32b1885e65d38f.tar.gz"
  version "0.17.1-pa.2"
  sha256 "7c9c2a9d4a8eaba2a9d797f353d5cc7fa74e7308290595657ff6e7910f04551a"
  license "MIT"
  head "https://github.com/part-avocado/apple-music-discord-rpc.git", branch: "main"

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
