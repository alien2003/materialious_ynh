#!/bin/bash

#=================================================
# COMMON VARIABLES AND CUSTOM HELPERS
#=================================================

# Fetch the Materialious source, keep only the app (in the 'materialious/' subdir),
# and apply the required patch for the PostgreSQL backend.
#
# Upstream declares the User.id column as `DataTypes.UUIDV4`. UUIDV4 is a default-value
# generator, not a column type: PostgreSQL rejects it ("type uuidv4 does not exist"),
# so sequelize.sync() fails and every request returns 500. SQLite silently tolerates it,
# which is why upstream appears to work with its default SQLite config. We rewrite it to
# a real UUID column with UUIDV4 as the default value.
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

    # Fix the upstream PostgreSQL incompatibility (see comment above).
    ynh_replace \
        --match="type: DataTypes.UUIDV4," \
        --replace="type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4," \
        --file="$install_dir/src/lib/server/database.ts"

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
