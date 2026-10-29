# Local MP3 playlists

The v15 menu adds M3U/M3U8 import from File Manager. It includes the v14 root
Refresh fix. This is currently an installed trial: parser and player-state
tests pass, and both generated audio fixtures decode to EOS. The device trace shows three entries playing low/high/low automatically,
with EOS after each and no taps between them. Owner audible acceptance is pending. Playlist creation/editing UI is still future work.

In File Manager, select a `.m3u` or `.m3u8`, choose Open, then Play. Entries run
in the file's order; repetitions are intentional. EOS starts the next entry,
and the last entry stops. Prev/Next still select within the active queue.

Example, with the playlist next to the files:

```text
#EXTM3U
z-first.mp3
a-second.mp3
z-first.mp3
```

Relative paths are resolved from the playlist directory. Absolute paths inside
onboard storage are accepted too. Only existing regular MP3 files whose resolved
paths stay under `/mnt/onboard` are loaded. HTTP/file URLs, nested playlists,
outside paths and missing/unsupported files are skipped. Blank/comment lines,
UTF-8 BOM and CRLF are supported; spaces in file names are preserved. The queue
limit is 256 tracks; oversized lines are skipped and files over 1 MiB refused.
The UI reports skipped entries and a truncated queue.

Tests cover explicit order/repetition, filename spaces, missing/remote/outside
entries, BOM/comments/CRLF, embedded NUL, line/file limits and empty input. Host
ASan/UBSan and actual ARM runs pass. Player-state tests cover active EOS advance,
final/paused EOS stopping and error stopping. No rendering/touch is exercised
by those tests; owner audible acceptance remains separate.

The original low/high test tones use [LAME's encoding API](https://github.com/lameproject/lame/blob/master/include/lame.h).
They contain generated sine waves, not owner music.
