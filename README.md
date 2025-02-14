# Dan's dotfiles

## Usage

Just run:

```sh
cd ~
git clone <this repo>
~/dotfiles/install.sh
```

**Note:**

- Cloning in `~` is required. The install script expects itself to exist there.
- Do not run the install script with `sudo`. The script elevates itself, and expects that it was executed by a non-root user.

To use in VS Code devcontainers, update the following settings:

```jsonc
{
    // Don't set `dotfiles.installCommand`, as we're using the default `install.sh` script name
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
| `DOTFILES_USER_NAME` | Dan Vicarel | My name
| `DOTFILES_USER_EMAIL` | <dan.vicarel@gmail.com> | My public email

## Script Notes

### GPG

On Windows, **sharing GPG keyrings between the host OS and WSL distros is not worth the effort**.
You can do some hacks on the command line to make this work (setting `GNUPGHOME` to the other operating system's `.gnpug` directory, symlinking the directory, etc.) but then graphical programs like GitKraken or VS Code will have trouble locking the keyring to list/edit keys.
Instead, just generate GPG keys separately in Windows (with Gpg4win) and in WSL.

**TODO**: Look into setting up a long-lived GPG agent either in WSL or on the host; the other OS may then be able to share keys through that.

Follow [this guide](https://dev.to/benjaminblack/signing-git-commits-with-modern-encryption-1koh) to generate the most secure GPG keys (as of this writing in Feb 2025).
Basically, create keys with `gpg --full-generate-key --expert`, and follow the prompts to create a Ed25519 key pair,
then edit that key to create a signing-only subkey. Store key passphrases in a password manager like 1Password.

Add the signing-only subkeys [to GitHub](https://docs.github.com/en/authentication/managing-commit-signature-verification/adding-a-gpg-key-to-your-github-account).

Other programs installed on Windows should use the Gpg4win keys automatically, but note the following:

- Make sure Git Bash is using the default `gpg` command (i.e., `which gpg` returns `/usr/bin/gpg` and `GNUPGHOME` is not overridden).
- In GitKraken, under "Preferences > Commit Signing" make sure that "GPG Program" is set to the default `gpg` with an appropriate "Signing Key" selected, and both "Sign Commits by Default" and "Sign Tags by Default" are checked. Also, under "Preferences > Profiles", check "Keep my .gitconfig updated with my GitKraken Desktop Profile preferences" and set the right key ID for each GitKraken profile.
- In VS Code settings, check "Git: Enable Commit Signing" (and similar checkboxes for extensions like Git Graph).
  - **TODO**: how to make commits _from VS Code_ while remoted into WSL

In all OS environments (Windows, WSL, Git Bash, etc.), make sure that the following git configs are set.
Most of the constant ones are set by the script(s) in this repo.

- `user.name` set to your name
- `user.email` set to your email
- `user.signingkey` set to the ID of the appropriate signing-only subkey
- `user.useconfigonly` set to `true` to require committer name/email to be set in config, not guessed by git
- `commit.gpgsign` and `tag.gpgsign` set to `true` (may be covered by checkboxes in GUI programs)

For devcontainers, any code that can be run in a Linux devcontainer is going to be code that we cloned into WSL.
Therefore, we can mount the GPG folder from WSL into the devcontainer so that the _container's_ GPG can use those keys.
Just add the following:

```jsonc
    // In devcontainer.json...
    "mounts": [
        // ...
        // Correct `<user>` will depend on the devcontainer image, but is often `vscode`
        "source=${localEnv:HOME}/.gnupg/,target=/home/<user>/.gnupg/,type=bind"
    ]
```

## Contributing

All install scripts:

- MUST exit with status 0 for success, 1 for a non-terminal error (does not prevent other scripts running), or >1 for terminal errors (immediately stop the main install script)
- MUST accept at least one argument, where first is path to a .env configuration file. MAY accept additional arguments/options.
- MUST be invokable from the main install script OR in isolation (with appropriate arguments/options)
- MUST be idempotent (can be run multiple times without additional side effects, like appending to the same file multiple times)
- MUST NOT require user input, so that they can run automatically, e.g., as devcontainers are being set up
- MUST NOT make assumptions about the current working directory
- SHOULD be POSIX scripts under the `scripts/` folder (relying on bash is generally okay)
- MAY call other scripts in series or in parallel
- MAY perform operations requiring elevated privileges (the entrypoint install script self-elevates itself before executing others)

## License

[MIT](./LICENSE)
