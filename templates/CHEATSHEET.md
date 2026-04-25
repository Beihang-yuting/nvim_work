# gvim_work Cheat Sheet

Press `<Space>` (leader) and wait — which-key shows everything.
Use `<Space>?` to fuzzy-search all keymaps.

## File / Search

| Key            | Action                       |
|----------------|------------------------------|
| `<Space><Space>` | Find files                 |
| `<Space>/`     | Live grep                    |
| `<Space>,`     | Switch buffer                |
| `<Space>fr`    | Recent (frecency)            |
| `<Space>sg`    | Live grep                    |
| `<Space>sw`    | Search word under cursor     |
| `<Space>sh`    | Search :help                 |
| `<Space>?`     | Search all keymaps           |
| `<Space>?h`    | Open this cheat sheet        |

## LSP / Code Navigation

| Key      | Action                       |
|----------|------------------------------|
| `gd`     | Go to definition             |
| `gD`     | Go to declaration            |
| `gr`     | Find references              |
| `gI`     | Go to implementation         |
| `gy`     | Go to type definition        |
| `K`      | Hover doc                    |
| `<C-t>`  | Jump back                    |
| `]d`/`[d`| Next/prev diagnostic         |
| `<Space>cs` | Document symbols          |
| `<Space>cS` | Workspace symbols         |
| `<Space>cr` | Rename                    |
| `<Space>ca` | Code action               |
| `<Space>cf` | Format buffer             |

## Alignment (mini.align)

| Key            | Action                          |
|----------------|---------------------------------|
| `ga` (visual)  | Interactive align               |
| `<Space>a=`    | Align paragraph by `=`          |
| `<Space>a:`    | Align by `:`                    |
| `<Space>a,`    | Align by `,`                    |
| `<Space>a\|`   | Align by `\|`                   |
| `<Space>a<`    | Align by `<=` (SV nonblocking)  |
| `<Space>a/`    | Align by `//`                   |
| `<Space>aa`    | Custom pattern                  |
| `<Space>aA`    | vim-easy-align (advanced)       |

## Run / Build

| Key         | Action                          |
|-------------|---------------------------------|
| `<Space>rr` | Run task menu                   |
| `<Space>rt` | Toggle task list                |
| `<Space>rm` | Run Makefile target             |
| `<Space>rp` | Run pytest current file         |
| `<Space>rl` | Re-run last task                |
| `<Space>rk` | Action on running task          |

## VCS / Simulation

| Key         | Action                          |
|-------------|---------------------------------|
| `<Space>vc` | VCS compile                     |
| `<Space>vs` | VCS simv (prompt UVM_TESTNAME)  |
| `<Space>vS` | Re-run last sim                 |
| `<Space>vw` | Open Verdi/DVE                  |
| `<Space>vq` | Clean workspace                 |

## UVM Snippets (insert mode + Tab)

| Trigger     | Expands to                      |
|-------------|---------------------------------|
| `uvc`       | uvm_component skeleton          |
| `uvo`       | uvm_object skeleton             |
| `uvm_test`  | uvm_test with env + objection   |
| `uvm_seq`   | uvm_sequence body               |
| `bldp`      | build_phase block               |
| `runp`      | run_phase block                 |
| `uvi/uvw/uve/uvf` | uvm_info/warning/error/fatal |
| `cdb`/`cdbs`| config_db get/set               |
| `tic`       | type_id::create                 |
| `fsm3`      | 3-stage FSM (Verilog)           |

## Diagnostics / Trouble

| Key          | Action                          |
|--------------|---------------------------------|
| `<Space>xx`  | Workspace diagnostics           |
| `<Space>xX`  | Buffer diagnostics              |
| `<Space>xq`  | Quickfix                        |
| `<Space>xs`  | Symbol outline                  |

## Git

| Key          | Action                          |
|--------------|---------------------------------|
| `<Space>gg`  | LazyGit                         |
| `<Space>gb`  | Blame line                      |
| `<Space>gd`  | Diff view                       |
| `]c`/`[c`    | Next/prev hunk                  |

## UI Toggle

| Key          | Action                          |
|--------------|---------------------------------|
| `<Space>uf`  | Toggle format-on-save           |
| `<Space>un`  | Toggle line numbers             |
| `<Space>ur`  | Toggle relative numbers         |
| `<Space>ub`  | Cycle theme                     |
| `<Space>uz`  | Zen mode                        |

---

For more, run `:Telescope keymaps` or press `<Space>?`.
