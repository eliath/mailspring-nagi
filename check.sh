#!/usr/bin/env bash
set -euo pipefail

# Compiles every Mailspring stylesheet against each theme, the same way
# Mailspring does at runtime, and fails on the first LESS error.
# Usage: ./check.sh [path/to/app.asar]

asar="${1:-/snap/mailspring/current/usr/share/mailspring/resources/app.asar}"
src="$(cd "$(dirname "$0")" && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

npx -y @electron/asar extract "$asar" "$work/app" >/dev/null
"$src/install.sh" "$work/packages" >/dev/null

for variant in light dark; do
  APP="$work/app" THEME="$work/packages/nagi-$variant/styles" node -e '
    const fs = require("fs");
    const path = require("path");
    const app = process.env.APP;
    const theme = process.env.THEME;
    const less = require(path.join(app, "node_modules/less"));
    const paths = [theme, path.join(app, "static/style"), path.join(app, "static/style/base")];

    const files = [path.join(theme, "index.less"), path.join(app, "static/style/index.less")];
    const pkgs = path.join(app, "internal_packages");
    for (const pkg of fs.readdirSync(pkgs)) {
      if (pkg.startsWith("ui-")) continue; // other themes
      const dir = path.join(pkgs, pkg, "styles");
      if (!fs.existsSync(dir)) continue;
      for (const f of fs.readdirSync(dir)) if (f.endsWith(".less")) files.push(path.join(dir, f));
    }

    let failed = 0;
    for (const file of files) {
      less.render(fs.readFileSync(file, "utf8"), { filename: file, syncImport: true, paths }, (err) => {
        if (!err) return;
        failed++;
        console.error(`${file}:${err.line}: ${err.message}`);
      });
    }
    console.log(`${path.basename(path.dirname(theme))}: ${files.length - failed}/${files.length} stylesheets compiled`);
    process.exit(failed ? 1 : 0);
  '
done
