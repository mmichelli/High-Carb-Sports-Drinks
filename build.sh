#!/usr/bin/env bash
# Build script for the Marathon Fuel static site.
#
# Regenerates favicon raster variants and the OG image from the SVG
# sources, copies the production files into ./dist, and zips the
# result. Intended for distribution and as a sanity check before
# deploying.
#
# Usage:  ./build.sh
# Outputs: dist/  and  marathon-fuel-<commit>.zip

set -euo pipefail

cd "$(dirname "$0")"

# --- requirements -----------------------------------------------------------
if ! command -v magick >/dev/null 2>&1; then
  echo "ERROR: ImageMagick (magick) is required." >&2
  echo "  arch:    sudo pacman -S imagemagick" >&2
  echo "  debian:  sudo apt install imagemagick" >&2
  echo "  macOS:   brew install imagemagick" >&2
  exit 1
fi

# --- version tag ------------------------------------------------------------
# Prefer an exact-match git tag on HEAD (e.g. v1.0.0); fall back to short
# commit sha; fall back to date when run outside git.
if [[ -d .git ]] && command -v git >/dev/null 2>&1; then
  VERSION="$(git describe --tags --exact-match HEAD 2>/dev/null \
              || git rev-parse --short HEAD 2>/dev/null \
              || echo "unversioned")"
else
  VERSION="$(date -u +%Y%m%d)"
fi
DIST_DIR="dist"
ZIP_NAME="marathon-fuel-${VERSION}.zip"

# Strip metadata + zero PNG timestamps so the build is reproducible.
PNG_REPRO=(-define png:exclude-chunks=date,time -strip)

echo "==> Building marathon-fuel ${VERSION}"

# --- regenerate raster favicons from favicon.svg ----------------------------
echo "==> Rasterising favicons from favicon.svg"
magick -background none -density 384 favicon.svg -resize 16x16  "${PNG_REPRO[@]}" favicon-16.png
magick -background none -density 384 favicon.svg -resize 32x32  "${PNG_REPRO[@]}" favicon-32.png
magick -background none -density 384 favicon.svg -resize 180x180 "${PNG_REPRO[@]}" apple-touch-icon.png
magick favicon-16.png favicon-32.png favicon.ico

# --- regenerate OG image from og-image.svg ----------------------------------
echo "==> Rasterising og-image.png from og-image.svg"
magick -background "#f4f4f0" -density 200 og-image.svg -resize 1200x630 "${PNG_REPRO[@]}" og-image.png

# --- assemble dist ----------------------------------------------------------
echo "==> Assembling ./${DIST_DIR}"
rm -rf "${DIST_DIR}"
mkdir -p "${DIST_DIR}/references"

cp index.html            "${DIST_DIR}/"
cp favicon.svg           "${DIST_DIR}/"
cp favicon.ico           "${DIST_DIR}/"
cp favicon-16.png        "${DIST_DIR}/"
cp favicon-32.png        "${DIST_DIR}/"
cp apple-touch-icon.png  "${DIST_DIR}/"
cp og-image.png          "${DIST_DIR}/"

# References folder — fetch script + any locally cached open-access PDFs +
# the markdown index. Generated PDFs are kept if present.
cp references/REFERENCES.md          "${DIST_DIR}/references/" 2>/dev/null || true
cp references/fetch-references.sh    "${DIST_DIR}/references/" 2>/dev/null || true
shopt -s nullglob
for pdf in references/*.pdf; do
  cp "${pdf}" "${DIST_DIR}/references/"
done
shopt -u nullglob

# --- zip --------------------------------------------------------------------
echo "==> Writing ${ZIP_NAME}"
rm -f "${ZIP_NAME}"
( cd "${DIST_DIR}" && zip -rq "../${ZIP_NAME}" . )

# --- summary ----------------------------------------------------------------
echo
echo "BUILD COMPLETE"
echo "  version : ${VERSION}"
echo "  dist    : ./${DIST_DIR}/  ($(find "${DIST_DIR}" -type f | wc -l) files, $(du -sh "${DIST_DIR}" | cut -f1))"
echo "  archive : ./${ZIP_NAME}      ($(du -h "${ZIP_NAME}" | cut -f1))"
echo
echo "Preview locally:  python3 -m http.server -d ${DIST_DIR} 8000"
