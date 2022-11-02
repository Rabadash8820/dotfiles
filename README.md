# Dan's dotfiles

## Usage

Just run:

```sh
cd ~
git clone <this repo>
sudo ~/dotfiles/install.sh
```

**Note: Cloning in `~` is required. The install script expects itself to exist there.**

To use in VS Code devcontainers, update the following settings:

```jsonc
{
    "dotfiles.installCommand": "sudo ~/dotfiles/install.sh",
    "dotfiles.repository": "<this-repo-url>",
    // etc.
}
```

## Configuration

Script will respect the following environment variables:

| Var | Value if undefined | Description
|--|--|--|
| `DOTFILES_HOME_DIR` | `/home/$SUDO_USER` | Home directory of the calling user.
| `DOTFILES_SHELL_RC_FILE` | `/home/$SUDO_USER/.bashrc` | Absolute path to the current shell's .*rc file.
| `DOTFILES_REPOS_FOLDER` | `/home/$SUDO_USER/repos` | Absolute path to folder where helper repos will be cloned/updated.

## Contributing

All install scripts:

- SHOULD be POSIX scripts under the `scripts/` folder (relying on bash is generally okay)
- MUST exit with status 0 for success, 1 for a non-terminal error (does not prevent other scripts running), or >1 for terminal errors (immediately stop the main install script)
- MUST accept at least one argument, where first is path to a .env configuration file. MAY accept additional arguments/options.
- MUST be invokable from the main install script OR in isolation (with appropriate arguments/options)
- MAY call other scripts in series or in parallel
- MUST NOT make assumptions about the current working directory
- MUST be idempotent (can be run multiple times without additional side effects, like appending to the same file multiple times)
- MAY perform operations requiring elevated privileges

## License

[MIT](./LICENSE)
