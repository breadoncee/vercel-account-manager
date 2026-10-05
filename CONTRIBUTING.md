# Contributing to vcm

Thanks for helping improve `vcm`. You can report bugs and suggest features in [GitHub Issues](https://github.com/breadoncee/vercel-account-manager/issues).

## Set up locally

You need macOS or Linux, a POSIX shell, and the [Vercel CLI](https://vercel.com/docs/cli). Node.js and npm are needed to run the package script or check the npm package.

```sh
git clone https://github.com/breadoncee/vercel-account-manager.git
cd vercel-account-manager
npm test
```

You can run the script from the clone with `./bin/vcm`. The test suite uses a fake `vercel` command and does not need access to your Vercel account.

## Make a change

1. Open an issue first for a substantial change so the approach can be discussed.
2. Create a branch, make your change, and update the README when behavior changes.
3. Add or update tests for changes to account, team, or project selection.
4. Run `npm test` and include the result in your pull request.

Keep the CLI compatible with the supported POSIX shell. Do not commit authentication files, access tokens, or real Vercel configuration directories. Tests should use temporary directories and fake credentials.

## Releases

Maintainers handle version changes, npm publication, and GitHub releases. Release tags use `v` followed by the package version, such as `v0.1.1`.

By contributing, you agree that your contribution will be licensed under the [MIT License](LICENSE).
