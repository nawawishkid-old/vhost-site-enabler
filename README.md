# Virtual host site enabler
Simple virtual host site enabling

Firstly developed for managing Docker compose which comprised of NGINX and Apache containers.

> Just a minimum viable script.

## Features
- Enable/disable site

## Usage
Use `.env` file to specified server's `sites-available` and `sites-enabled` directory and `hosts` file. If not specified, the app will use `./sites-available`, `./sites-enabled`, and `/etc/hosts` as default value of aforementioned respectively.

### Commands
- `ensite FILENAME` -- Create soft link of `FILENAME` which is a name of a file without `.conf` extension in `sites-available` directory to `sites-enabled` directory.
- `dissite FILENAME` -- Remove soft link file from `sites-enabled` directory.
- `addhost IP_ADDR HOSTNAME [HOSTNAME]...` -- Append IP address and hostname of virtual host to `hosts` file.
- `removehost HOSTNAME` -- Remove IP address and hostname from `hosts` file.
