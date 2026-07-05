# Materialious for YunoHost

[![Integration level](https://img.shields.io/badge/status-working-brightgreen)](#)
[![Install Materialious with YunoHost](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=materialious)

> *This package lets you install Materialious quickly and simply on a YunoHost server.
If you don't have YunoHost, please consult [the guide](https://yunohost.org/#/install) to
learn how to install it.*

## Overview

Materialious is a modern Material Design front-end for YouTube / Invidious.

This package runs it in **full backend mode** with its own account system on top of a
**SQLite** database (subscriptions, history and settings stored server-side,
end-to-end encrypted by the app). The app source is used **unmodified**.

**Shipped version:** 1.17.2~ynh1

## Screenshots

See the upstream project: <https://github.com/Materialious/Materialious>

## Important

- **Full-domain app:** Materialious is built with an empty base path and only works at the
  **root of a (sub)domain**. There is no sub-path install option.
- **No YunoHost SSO/LDAP:** the app manages its own accounts. It is exposed publicly at the
  YunoHost level and enforces authentication itself.
- **Registration** is disabled by default. Toggle it from the app's **Config Panel** to
  create accounts, then turn it back off. See [the admin doc](./doc/ADMIN.md).
- The package compiles the `sqlite3` native module from source (its published prebuilt
  binary requires a newer glibc than Debian 12 provides). This only touches the app's
  dependencies — the Materialious source itself is left untouched.

## Documentation and resources

- Upstream app code repository: <https://github.com/Materialious/Materialious>
- YunoHost documentation for this app: see [`doc/`](./doc/)

## Developer info

Send your pull request to the packaging repository.

To try the testing branch, please proceed like that:

```bash
sudo yunohost app install https://github.com/YOURORG/materialious_ynh/tree/testing --debug
# or
sudo yunohost app upgrade materialious -u https://github.com/YOURORG/materialious_ynh/tree/testing --debug
```

**More info regarding app packaging:** <https://yunohost.org/packaging_apps>
