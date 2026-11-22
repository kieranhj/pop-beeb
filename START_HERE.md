# pop-beeb: start here

Prince of Persia: a port of Jordan Mechner's Apple II original to the BBC Master 128, in 6502 for
BeebAsm (Kieran Connell, with SM). Released game (v1.1, 2018); this checkout is the later
`version-1.2` branch.

| | |
|---|---|
| GitHub | https://github.com/kieranhj/pop-beeb (public) |
| Upstream | Jordan Mechner's Apple II Prince of Persia source |
| Local path | D:\beeb\mine\pop-beeb (moved from OneDrive\BEEB\Repos\pop-beeb on 2026-11-22) |
| Branch | version-1.2; others: master (v1.1, 2018-04-01), release-candidate, memory-map-info, audio-implementation, beeb_row_order, export-experiment, hack-force-cut, screen-draw, shadow-palette, show-build-version, testing-branch |
| Last commit | 2020-07-15: Hacky 'fixes' to support DFS 2.45 |

## What's in here
- `pop-beeb.asm` / `pop-beeb.h.asm` top level; `Source/` the ported 6502 code; `lib/` support code
- `disc/` disc layout (`pop-beeb-layout.asm`, template) and the built/crunched files that go on it
- `Images/`, `Levels/`, `audio/` converted assets; `pop2beeb/` (Visual Studio converter tool), `Unpack/`
- `Notes/` notes, memory map, disc layout, instructions; `Reference/`, `Other/`
- `Releases/` past release .ssd files and their compile logs; `pop-beeb.ssd` the current disc (tracked)
- `bin/` beebasm.exe, pucrunch.exe, bbcim.exe

## Build and run
- `make`: runs `make.bat` via the wrapper Makefile (added 2026-11-22): writes version.txt,
  assembles with `bin\BeebAsm.exe` (log in compile.txt), pucrunches the code files and builds
  `pop-beeb.ssd`. **Works** (checked 2026-11-22). `make help` lists targets.
- Note: a build rewrites the tracked `pop-beeb.ssd` (and the tracked crunched `disc\*.pu.bin`
  when their sources change), so expect `git status` to show it modified afterwards.
- `make.bat vsc` sends assembler output to the console instead of compile.txt.
- Other scripts: `compress_assets.bat`, `make_disc_image.bat`, `runkc.bat` (gitignored, emulator).
- Run `pop-beeb.ssd` on a Master 128 (or b2/jsbeeb, model Master); keys are in README.md.

## Local changes
- Untracked `.vscode/settings.json`. No stashes; no snapshot branches.
- version-1.2 adds DFS 2.45 support hacks (2020) over the v1.1 release on master.

## Status and next steps
- Released; last work 2020 (DFS 2.45 support on version-1.2, not merged to master). No TODO or plan
  file found beyond Notes/.

## See also
README.md (keys, credits, Stardot thread), Notes/, Releases/.
