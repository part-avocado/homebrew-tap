# homebrew-tap

Personal Homebrew tap for [part-avocado](https://github.com/part-avocado).

```
brew tap part-avocado/tap
brew install part-avocado/tap/apple-music-discord-rpc
```

## apple-music-discord-rpc

A patched build of [NextFire/apple-music-discord-rpc](https://github.com/NextFire/apple-music-discord-rpc)
(pinned to release `0.17.1`, same as the upstream `nextfire/homebrew-tap` formula).

### Why this exists

As of 2026-08-14, the upstream formula fails to start with:

```
error: Module not found "https://win32.deno.dev/0.4.1/System.IO".
    at https://deno.land/x/namedpipe@0.1.2/deps.ts:1:21
```

Root cause: `discord_rpc@0.3.2` statically imports the Windows-only
`namedpipe@0.1.2` module, whose `deps.ts` unconditionally pulls 7 files from
`win32.deno.dev`. That host (a Deno Deploy Classic app) was sunset on
2026-07-20 and now 404s permanently. Deno resolves the entire module graph
before running anything, so the app can't start on macOS even though that
Windows-only code path (`namedpipe.connect()`) is never actually reached —
`discord_rpc`'s `findIPC()` only calls it when `Deno.build.os === "windows"`;
macOS uses a Unix socket instead.

This formula's `install` step writes a local `deno.json` import map next to
`music-rpc.ts` that redirects those 7 dead URLs to small local no-op stubs,
so module resolution succeeds without needing the dead host or changing any
code path that actually runs on macOS.

If/when upstream (`discord_rpc`, `namedpipe`, or `apple-music-discord-rpc`
itself) fixes this for real, this tap can go back to tracking
`nextfire/homebrew-tap` directly.
