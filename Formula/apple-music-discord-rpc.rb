class AppleMusicDiscordRpc < Formula
  desc "Discord Rich Presence client for the macOS Apple Music app (part-avocado fork)"
  homepage "https://github.com/part-avocado/apple-music-discord-rpc"
  url "https://github.com/part-avocado/apple-music-discord-rpc/archive/a7b4259fa6d34bebbc18fbc3fd5a12ada0ebcff9.tar.gz"
  version "0.17.1-pa.1"
  sha256 "a871b6ed0f15eb55f8d2050c24bb6ab2688bab1ac625570c4a6a26ebcc1e26ae"
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
