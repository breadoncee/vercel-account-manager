# vcm

`vcm` is a small account and team manager for the [Vercel CLI](https://vercel.com/docs/cli). It gives separate Vercel logins names, remembers the selected account, and passes other commands through to Vercel. Team switching uses Vercel's own `switch` command within the selected account.

## Install with npm

Install the [Vercel CLI](https://vercel.com/docs/cli) first. Once this repository is on GitHub, people can install `vcm` directly from it:

```sh
npm install -g vercel
npm install -g github:YOUR_USERNAME/vercel-account-manager
```

Replace `YOUR_USERNAME` with the GitHub owner. The package exposes the `vcm` command on macOS and Linux. It is not published to the npm registry yet, so `npm install -g vercel-account-manager` will not work until it is published there.

## Install from a clone

Clone this repository and run:

```sh
./install.sh
```

The installer copies `vcm` to `~/.local/bin`. If that directory is not on your `PATH`, add this line to your shell setup file (for example, `~/.zshrc`) and open a new terminal:

```sh
export PATH="$HOME/.local/bin:$PATH"
```

To update a previous installation after pulling changes, run `./install.sh --force`. Set `VCM_INSTALL_DIR` to an absolute path if you prefer a different installation directory.

## Add accounts

If you are already logged in with the Vercel CLI, register that login without authenticating again:

```sh
vcm add personal --default
```

Add another account with a one-time login. The new account is selected when login completes:

```sh
vcm add work
```

If an account already has its own Vercel global config directory, register that exact directory without logging in again:

```sh
vcm add work "$HOME/.config/vercel-work"
```

Use `vcm login work` if you need to refresh that account's login later.

## Switch accounts and teams

```sh
vcm list                    # Show saved accounts; * marks the selected one
vcm use personal            # Switch accounts
vcm current                 # Print the selected account name
vcm whoami                  # Ask Vercel which user is logged in

vcm teams                   # List teams on the selected account
vcm team                    # Choose a team interactively
vcm team my-team            # Switch directly to a team
vcm use work my-team        # Switch account and team together

vcm deploy                  # Pass any other command to Vercel
```

Each account retains its own team selection. Vercel saves the selected team in that account's [global CLI configuration](https://vercel.com/docs/project-configuration/global-configuration).

When working in an already linked project, check its local `.vercel/project.json` before deploying. The [project link](https://vercel.com/docs/cli/project-linking) identifies a specific Vercel project and organization; changing accounts does not change that link.

## Where data is stored

`vcm` stores account names and its selected account under `~/.config/vcm`. New account logins are saved in separate Vercel config directories below that location. Set `VCM_HOME` to use a different directory. Existing installations using the earlier `vercel-account-switcher` or `vercel-account-manager` directories are read automatically.

Authentication files stay in your user config directory, outside this repository. The installer only copies the script.

## Test

```sh
sh tests/run.sh
```

The test uses a fake `vercel` command; it does not access your accounts.
