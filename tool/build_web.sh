#!/usr/bin/env bash
# Builds the web app into build/web and deploys it live to the `mindful`
# Cloudflare Pages project (production branch). Builds WebAssembly by
# default (skwasm in Chrome/Edge/Firefox; other browsers get the JS build
# that ships alongside). Options (the rest go to `flutter build web`):
#   --no-deploy  only build
#   --preview    deploy to the `preview` branch's URL instead of live
#   --no-wasm    JS build only
# Every web-side dependency must work under dart2wasm at runtime, not just
# compile: hive 2.x compiled but threw UnimplementedError on every box,
# which is why the app is on hive_ce.
# Refuses to build if .env still holds a
# Gemini key: on web every bundled asset is a public file, so the key would
# be downloadable from /assets/.env. Gemini goes through the gemini-proxy
# Edge Function instead (see SPEC.md Web).
set -euo pipefail
cd "$(dirname "$0")/.."

if grep -Eq '^[[:space:]]*GEMINI_API_KEY[[:space:]]*=[[:space:]]*[^[:space:]#]' .env; then
  echo "error: .env has GEMINI_API_KEY set — remove it before a web build." >&2
  echo "       It lives in the gemini-proxy function's secrets instead:" >&2
  echo "       supabase secrets set GEMINI_API_KEY=..." >&2
  exit 1
fi

deploy=true
branch=main
wasm=true
build_args=()
for arg in "$@"; do
  case "$arg" in
    --no-deploy) deploy=false ;;
    --preview) branch=preview ;;
    --no-wasm) wasm=false ;;
    --wasm) ;; # the default already
    *) build_args+=("$arg") ;;
  esac
done
[[ "$wasm" == true ]] && build_args+=(--wasm)

flutter build web --release ${build_args[@]+"${build_args[@]}"}

# Preconnect to the Supabase project (auth + data are the first requests
# after startup). Its URL lives in .env, so it's filled in here rather
# than hardcoded in web/index.html.
supabase_url=$(sed -n 's/^[[:space:]]*SUPABASE_URL[[:space:]]*=[[:space:]]*//p' .env | tr -d "\"' \r")
if [[ -n "$supabase_url" ]]; then
  sed -i.bak "s|<!-- supabase-preconnect -->|<link rel=\"preconnect\" href=\"$supabase_url\" crossorigin>|" \
    build/web/index.html
  rm build/web/index.html.bak
fi

# index.html preloads main.dart.wasm in browsers that will run it; a JS-only
# build has no such file, so it must always preload main.dart.js instead.
if [[ "$wasm" == false ]]; then
  sed -i.bak 's/var hasWasmBuild = true;/var hasWasmBuild = false;/' build/web/index.html
  rm build/web/index.html.bak
fi

if [[ "$deploy" == true ]]; then
  # main is the production branch (the live URL); anything else gets its
  # own preview alias. First run asks to log in (npx wrangler login).
  npx --yes wrangler pages deploy build/web \
    --project-name mindful --branch "$branch" --commit-dirty=true
fi
