class AppleMusicDiscordRpc < Formula
  desc "Discord Rich Presence Client for the macOS Apple Music app and iTunes"
  homepage "https://github.com/NextFire/apple-music-discord-rpc"
  url "https://github.com/NextFire/apple-music-discord-rpc/archive/refs/tags/0.17.1.tar.gz"
  sha256 "57298babb80724f4973539cb3a5b64416a536e2121193dbc280ced498a851171"
  license "MIT"
  head "https://github.com/NextFire/apple-music-discord-rpc.git", branch: "main"

  # Upstream's discord_rpc@0.3.2 dependency statically imports the Windows-only
  # `namedpipe` module, whose deps.ts pulls 7 files from win32.deno.dev. That
  # host (Deno Deploy Classic) was sunset 2026-07-20 and now 404s permanently,
  # so Deno's module graph resolution fails on startup even though this code
  # path is never reached on macOS (discord_rpc only calls it when
  # Deno.build.os == "windows"; macOS uses a Unix socket instead).
  #
  # Fix: ship a local deno.json import map that redirects those 7 dead URLs to
  # inert local stubs, so module resolution succeeds without needing the dead
  # host or touching any code that actually runs on macOS.
  depends_on "deno"

  def install
    bin.install "music-rpc.ts"

    stubs = bin/".deno-stubs"
    stubs.mkpath
    (stubs/"empty.ts").write "export {};\n"
    (stubs/"overlapped.ts").write "export class OverlappedPromise {}\n"
    (stubs/"error.ts").write "export function unwrap(v: unknown) { return v; }\n"

    (bin/"deno.json").write <<~JSON
      {
        "imports": {
          "https://win32.deno.dev/0.4.1/System.IO": "./.deno-stubs/empty.ts",
          "https://win32.deno.dev/0.4.1/System.Pipes": "./.deno-stubs/empty.ts",
          "https://win32.deno.dev/0.4.1/System.Diagnostics.Debug": "./.deno-stubs/empty.ts",
          "https://win32.deno.dev/0.4.1/Storage.FileSystem": "./.deno-stubs/empty.ts",
          "https://win32.deno.dev/0.4.1/Foundation": "./.deno-stubs/empty.ts",
          "https://win32.deno.dev/0.4.1/overlapped": "./.deno-stubs/overlapped.ts",
          "https://win32.deno.dev/0.4.1/error": "./.deno-stubs/error.ts"
        }
      }
    JSON
  end

  service do
    run opt_bin/"music-rpc.ts"
    keep_alive true
    environment_variables PATH: std_service_path_env
    working_dir var/"apple-music-discord-rpc"
    error_log_path var/"apple-music-discord-rpc/music-rpc.log"
  end

  test do
    assert_predicate bin/"music-rpc.ts", :exist?
    assert_predicate bin/"deno.json", :exist?
  end
end
