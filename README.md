# Tableside: Scripts

Scripts for development and testing of the Tableside application.

## Usage

Use  `./tableside` script in the repository root to use the scripts.

1. Clone the repository:

```sh
git clone https://github.com/Table-Side/Scripts.git
```

2. Change to the repository directory:

```sh
cd Scripts
```

3. Set up your environment variables in a `.env` file (see [.env.dist](/.env.dist) for an example):

```sh
cp .env.dist .env
nano .env
```

4. Run the script:

```sh
./tableside --help
```

The script will prompt you for missing environment variables.

## Scripts

- `./tableside seed`: Seed the database with data from [`data/seed.json`](/data/seed.json).

- You can use the `--help` flag to get more information about each script.
    ```sh
    ./tableside --help
    ```

## Development

To run the scripts in DEBUG mode, simply set the `DEBUG` environment variable to `1` or `true`:

```sh
DEBUG=1 ./tableside seed
```
