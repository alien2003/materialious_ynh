#!/bin/bash

#=================================================
# COMMON VARIABLES AND CUSTOM HELPERS
#=================================================

# Fetch the Materialious source and keep only the app (in the 'materialious/' subdir).
# The app's source is used verbatim — no patching — since the SQLite backend it was
# designed around is what we run.
materialious_setup_source() {
    local tmpdir
    tmpdir="$(mktemp -d)"

    # Download, verify and extract the release tarball (top-level dir is stripped).
    ynh_setup_source --dest_dir="$tmpdir"

    # The app lives in the 'materialious/' subdirectory of the repository.
    ynh_safe_rm "$install_dir"
    mkdir -p "$install_dir"
    cp -a "$tmpdir/materialious/." "$install_dir/"
    ynh_safe_rm "$tmpdir"

    chown -R "$app:www-data" "$install_dir"
}

# Install node dependencies and build the SvelteKit app with the node backend.
# PUBLIC_BUILD_WITH_BACKEND=true is required at build time so svelte.config.js selects
# @sveltejs/adapter-node (and produces the 'build/' directory started with `node build`).
materialious_build() {
    pushd "$install_dir" >/dev/null
        ynh_hide_warnings ynh_exec_as_app env \
            PUBLIC_BUILD_WITH_BACKEND=true \
            npm_config_cache="$install_dir/.npm" \
            npm ci

        # Rebuild the sqlite3 native binding from source. The binary published on npm is
        # linked against a newer glibc (2.38) than Debian 12 provides (2.36), so the
        # prebuilt fetched by `npm ci` fails to load at runtime (ERR_DLOPEN_FAILED).
        # npm's script gating also prevents `npm ci`/`npm rebuild` from compiling it, so
        # we invoke node-gyp directly inside the package.
        ynh_hide_warnings ynh_exec_as_app env \
            npm_config_cache="$install_dir/.npm" \
            bash -c 'cd "$0/node_modules/sqlite3" && ../.bin/node-gyp rebuild' "$install_dir"

        ynh_hide_warnings ynh_exec_as_app env \
            PUBLIC_BUILD_WITH_BACKEND=true \
            npm_config_cache="$install_dir/.npm" \
            npm run build

        # Drop dev dependencies to shrink the install (matches upstream FullDockerfile).
        ynh_hide_warnings ynh_exec_as_app env \
            npm_config_cache="$install_dir/.npm" \
            npm prune --omit=dev

        # The npm cache is only needed during the build.
        ynh_safe_rm "$install_dir/.npm"
    popd >/dev/null

    chown -R "$app:www-data" "$install_dir"
}

# (Re)generate the runtime env file from the current app settings and secure it.
# Called on install, upgrade, and from the config panel (scripts/config).
materialious_render_env() {
    ynh_config_add --template=".env" --destination="$install_dir/.env"
    chmod 600 "$install_dir/.env"
    chown "$app:$app" "$install_dir/.env"
}
