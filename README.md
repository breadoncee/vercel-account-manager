<img src="https://raw.githubusercontent.com/breadoncee/vercel-account-manager/main/assets/logo.svg" width="64" height="64" alt="vcm pixel logo">

# vcm

Manage multiple [Vercel CLI](https://vercel.com/docs/cli) accounts and teams. Set a global default, or pin an account and team to a project with `.vcmrc`.

[npm](https://www.npmjs.com/package/vercel-account-manager) · [Releases](https://github.com/breadoncee/vercel-account-manager/releases) · [MIT license](LICENSE)

## Quick start

Install the Vercel CLI and [`vercel-account-manager` from npm](https://www.npmjs.com/package/vercel-account-manager):

```sh
npm install -g vercel
npm install -g vercel-account-manager
```

If you are already logged in to Vercel, keep that login as `personal`. Add a second account with a one-time login, then choose the default and pin a team to a project:

```sh
vcm add personal --default
vcm add work
vcm default personal

cd my-project
vcm use work my-team
vcm status
vcm deploy
```

The package exposes `vcm` on macOS and Linux. Replace `work`, `my-team`, and `my-project` with your names.

![Terminal example showing global account selection, a project account and team, and status](https://raw.githubusercontent.com/breadoncee/vercel-account-manager/main/assets/demo.gif)

The project selection lives in `.vcmrc`. Other projects keep using your global default.

## How selection works

| Where you run a command | Account and team used |
| --- | --- |
| In a project with `.vcmrc` | The account and optional team in the closest `.vcmrc` |
| Elsewhere | The global default account and that account's Vercel CLI default team |

An explicit `--scope` or `--team` on a Vercel command takes precedence over a project's team setting.

## Install from a clone

Clone this repository and run:

```sh
git clone https://github.com/breadoncee/vercel-account-manager.git
cd vercel-account-manager
./install.sh
```

The installer copies `vcm` to `~/.local/bin`. If that directory is not on your `PATH`, add this line to your shell setup file (for example, `~/.zshrc`) and open a new terminal:

```sh
export PATH="$HOME/.local/bin:$PATH"
```

To update a previous installation after pulling changes, run `./install.sh --force`. Set `VCM_INSTALL_DIR` to an absolute path if you prefer a different installation directory.

## Manage accounts

If you are already logged in with the Vercel CLI, register that login without authenticating again:

```sh
vcm add personal --default
```

Add another account with a one-time login. The new account becomes the global default when login completes:

```sh
vcm add work
```

If an account already has its own Vercel global config directory, register that exact directory without logging in again:

```sh
vcm add work "$HOME/.config/vercel-work"
```

Use `vcm login work` if you need to refresh that account's login later.

To change a saved account label without logging in again, run:

```sh
vcm rename work client
```

This updates the global default and the closest project's `.vcmrc` if either uses the old name. The Vercel login stays in its existing config directory. Update `.vcmrc` files in other projects that use the old name.

To remove a saved label, run `vcm account remove client`. This unregisters it from `vcm` and clears the global default if that account was selected. It keeps the Vercel login files. Update any project `.vcmrc` files that still name the removed account, then use `vcm default NAME` to choose another global default.

## Pin an account and team to a project

From the project directory, run:

```sh
vcm use work my-team
vcm status
vcm deploy
```

`vcm use` writes `.vcmrc` in the current directory:

```text
account=work
team=my-team
```

Commands run in that directory or its subdirectories use this account and team automatically. The closest `.vcmrc` wins. The file contains only an account name and team slug, not credentials. Commit it if your collaborators use the same account names; otherwise add `.vcmrc` to that project's `.gitignore`.

Remove the project's `.vcmrc` when you want it to use the global fallback again.

Project team selection is passed to Vercel as `--scope` for each command, so it does not change the account's global team. An account can also be pinned without a team using `vcm use work`; in that case Vercel's default team for that account applies.

## Set the global fallback

Outside projects with a `.vcmrc`, `vcm` uses the global default account. Set it from anywhere with:

```sh
vcm default personal
vcm default work my-team
```

Run `vcm default` to show the current global default. The existing `vcm use --global NAME [TEAM]` form also works.

When a team is given with `vcm default` or `vcm use --global`, `vcm` uses Vercel's `switch` command to save that team for the account. Each account retains its own global team selection.

## Other commands

```sh
vcm list                    # Show saved accounts; * marks the global default
vcm current                 # Print the effective account name
vcm current --global        # Print the global default account name
vcm status                  # Show effective account, team, and config source
vcm whoami                  # Ask Vercel which user is logged in

vcm teams                   # List teams on the effective account
vcm team my-team            # Change the current project's team, or global team outside a project
vcm team --global my-team   # Change the global default account's team
vcm team                    # Choose a team interactively

vcm deploy                  # Pass any other command to Vercel
```

Vercel saves a globally selected team in that account's [global CLI configuration](https://vercel.com/docs/project-configuration/global-configuration).

When `vcm teams` shows a team name that differs from its `id` column, use the value in the `id` column with `vcm team`. For example, if the row is `dfo1  DFO`, run `vcm team dfo1`; `DFO` is the display name.

When working in an already linked project, check its local `.vercel/project.json` before deploying. The [project link](https://vercel.com/docs/cli/project-linking) identifies a specific Vercel project and organization; changing accounts does not change that link.

## Where data is stored

`vcm` stores account names and its global default account under `~/.config/vcm`. New account logins are saved in separate Vercel config directories below that location. Set `VCM_HOME` to use a different directory. Existing installations using the earlier `vercel-account-switcher` or `vercel-account-manager` directories are read automatically.

Authentication files stay in your user config directory, outside this repository. The installer only copies the script.

## Test

```sh
sh tests/run.sh
```

The test uses a fake `vercel` command; it does not access your accounts.

## Contributing

Bug reports and pull requests are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for setup, tests, and contribution guidelines.

## License

MIT. See [LICENSE](LICENSE).
