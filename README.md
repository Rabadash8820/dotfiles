# Dan's dotfiles

## Usage

Just run:

```sh
git clone <this repo>
cd <this repo>
sudo ./install.sh
```

## Contributing

All install scripts:

- SHOULD be POSIX scripts under the `scripts/` folder (relying on bash is generally okay)
- MUST exit with status 0 for success, 1 for a non-terminal error (does not prevent other scripts running), or >1 for terminal errors (immediately stop the main install script)
- MAY accept arguments/options
- MUST be invokable from the main install script OR in isolation (with appropriate arguments/options)
- MAY call other scripts in series or in parallel
- MUST NOT make assumptions about the current working directory
- MUST be idempotent (can be run multiple times without additional side effects)
- MAY perform operations requiring elevated privileges

## License

[MIT](./LICENSE)
