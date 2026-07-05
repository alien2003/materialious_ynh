## First login / creating accounts

Registration is **disabled by default** (so the instance isn't open to the world). To
create your account(s):

1. In the YunoHost webadmin, open **Applications → Materialious → Config Panel**.
2. Under **Accounts**, turn **Allow new account registration** ON and save. The service
   restarts automatically.
3. Visit your Materialious domain and register your account(s).
4. Go back to the Config Panel and turn registration **OFF** again.

You can grant admin rights to one or more accounts via the **Admin usernames** field in
the same panel (comma-separated, e.g. `alice,bob`).

The same Config Panel has a **Disable the proof-of-work captcha** switch. The captcha only
works over HTTPS and can be cumbersome; turning it off removes it from login/registration
(the built-in rate-limiting of 5 attempts/minute on those endpoints still applies).

## Important notes

- **This app takes the whole (sub)domain.** It is built to run only at the root of a
  domain and cannot be installed on a sub-path.
- **Own account system, no YunoHost SSO/LDAP.** Materialious does not use YunoHost users;
  it manages its own accounts. At the YunoHost level the app is public (visitors), and
  access is gated by Materialious itself (`PUBLIC_REQUIRE_AUTH=true`).
- **Cookie secret is preserved across upgrades** (stored in the app settings and included
  in backups), so upgrading does not log everyone out.

## Configuration internals

Runtime configuration lives in `/var/www/materialious/.env` (mode 600, owned by the app),
loaded by the systemd service. The two "Accounts" values are managed through the Config
Panel; other values (secrets, database URI, backend/auth mode) are generated from the app
settings and should not be edited by hand.

The SQLite database file is at `/home/yunohost.app/materialious/materialious.db`. It is
included in YunoHost backups (as part of the app's data directory).

## Invidious backend

Materialious needs an Invidious instance to talk to. You can set a default one in the
app's own **Settings** page inside Materialious, or point it at a public instance.
