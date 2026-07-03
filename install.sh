#!/usr/bin/env bash
#
# Olympus RolePlay — install.sh
# Κατεβάζει τα prebuilt releases (.zip) των third-party resources
# (QBox + ox_* + vMenu + spawnmanager) που δεν είναι committed στο repo.
#
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QBOX_DIR="$ROOT_DIR/resources/[qbox]"
OX_DIR="$ROOT_DIR/resources/[ox]"
STANDALONE_DIR="$ROOT_DIR/resources/[standalone]"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()    { echo -e "${YELLOW}==>${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
fail()    { echo -e "${RED}[ERROR]${NC} $1"; }

# ---------------------------------------------------
# 1. Έλεγχος downloader (curl ή wget) και unzip
# ---------------------------------------------------
DOWNLOADER=""
if command -v curl >/dev/null 2>&1; then
    DOWNLOADER="curl"
elif command -v wget >/dev/null 2>&1; then
    DOWNLOADER="wget"
else
    fail "Δεν βρέθηκε ούτε curl ούτε wget. Εγκατέστησε ένα από τα δύο και ξανατρέξε το script."
    exit 1
fi
success "Downloader: $DOWNLOADER"

if ! command -v unzip >/dev/null 2>&1; then
    fail "Το unzip δεν είναι εγκατεστημένο. Εγκατέστησέ το και ξανατρέξε το script."
    exit 1
fi
success "Το unzip είναι εγκατεστημένο"

fetch_url() {
    # fetch_url <url>  -> τυπώνει το response body στο stdout
    local url="$1"
    if [ "$DOWNLOADER" = "curl" ]; then
        curl -sL "$url"
    else
        wget -q -O - "$url"
    fi
}

download() {
    # download <url> <output_file>
    # Σημείωση: κάνουμε cd στον φάκελο του output και χρησιμοποιούμε relative
    # filename, γιατί το native curl.exe (mingw) σε Git Bash/MSYS χαλάει το
    # path translation όταν περνάμε absolute path με αγκύλες (π.χ. .../[ox]/...).
    local url="$1"
    local output="$2"
    local out_dir out_file

    out_dir="$(dirname "$output")"
    out_file="$(basename "$output")"

    if [ "$DOWNLOADER" = "curl" ]; then
        (cd "$out_dir" && curl -sL -o "$out_file" "$url")
    else
        (cd "$out_dir" && wget -q -O "$out_file" "$url")
    fi
}

resolve_latest_zip_url() {
    # resolve_latest_zip_url <owner/repo>
    # Βρίσκει το πρώτο .zip asset του τελευταίου release μέσω του GitHub API.
    # Χρησιμοποιείται για resources (π.χ. vMenu) που δεν έχουν σταθερό
    # filename στο "releases/latest/download/..." (το asset περιέχει version number).
    local repo="$1"
    fetch_url "https://api.github.com/repos/$repo/releases/latest" \
        | grep -oE '"browser_download_url":[[:space:]]*"[^"]+\.zip"' \
        | head -n1 \
        | grep -oE 'https://[^"]+\.zip'
}

mkdir -p "$QBOX_DIR" "$OX_DIR" "$STANDALONE_DIR"

# ---------------------------------------------------
# 2. Βοηθητική συνάρτηση λήψης prebuilt release .zip
#    install_resource <zip_url> <target_dir> <resource_name> <has_wrapper: yes|no>
#
#    has_wrapper=yes -> το zip περιέχει έναν φάκελο <resource_name>/ στη ρίζα
#                        (π.χ. ox_lib.zip -> ox_lib/fxmanifest.lua, ...)
#    has_wrapper=no  -> το zip περιέχει τα αρχεία απευθείας στη ρίζα
#                        (π.χ. vMenu-x.y.z.zip -> fxmanifest.lua, ...)
# ---------------------------------------------------
install_resource() {
    local zip_url="$1"
    local target_dir="$2"
    local name="$3"
    local has_wrapper="${4:-yes}"
    local zip_path="$target_dir/$name.zip"
    local extract_dir="$target_dir/.${name}_extract"

    if [ -d "$target_dir/$name" ]; then
        info "Το $name υπάρχει ήδη στο $target_dir — παραλείπεται (διέγραψέ το χειροκίνητα αν θες re-download)."
        return 0
    fi

    if [ -z "$zip_url" ]; then
        fail "Δεν βρέθηκε .zip asset για το $name."
        exit 1
    fi

    info "Κατεβάζω το $name (prebuilt release)..."
    if ! download "$zip_url" "$zip_path"; then
        fail "Αποτυχία λήψης του $name από $zip_url"
        exit 1
    fi

    if [ ! -s "$zip_path" ]; then
        fail "Το $name.zip κατέβηκε άδειο — έλεγξε το URL: $zip_url"
        rm -f "$zip_path"
        exit 1
    fi

    rm -rf "$extract_dir"
    mkdir -p "$extract_dir"

    if ! unzip -q -o "$zip_path" -d "$extract_dir"; then
        fail "Αποτυχία εξαγωγής του $name.zip"
        rm -f "$zip_path"
        rm -rf "$extract_dir"
        exit 1
    fi

    if [ "$has_wrapper" = "yes" ] && [ -d "$extract_dir/$name" ]; then
        mv "$extract_dir/$name" "$target_dir/$name"
        rm -rf "$extract_dir"
    else
        # Το zip δεν έχει wrapper folder (ή δεν βρέθηκε) -> μετακίνησε ό,τι εξήχθη.
        mv "$extract_dir" "$target_dir/$name"
    fi

    rm -f "$zip_path"
    success "$name κατέβηκε και εγκαταστάθηκε επιτυχώς στο $target_dir/$name"
}

# ---------------------------------------------------
# 3. Λήψη resources (prebuilt releases, σταθερό "latest/download" filename)
# ---------------------------------------------------
install_resource "https://github.com/Qbox-project/qbx_core/releases/latest/download/qbx_core.zip"      "$QBOX_DIR" "qbx_core"     "yes"
install_resource "https://github.com/overextended/ox_lib/releases/latest/download/ox_lib.zip"          "$OX_DIR"   "ox_lib"       "yes"
install_resource "https://github.com/overextended/oxmysql/releases/latest/download/oxmysql.zip"        "$OX_DIR"   "oxmysql"      "yes"
install_resource "https://github.com/overextended/ox_inventory/releases/latest/download/ox_inventory.zip" "$OX_DIR" "ox_inventory" "yes"

# ---------------------------------------------------
# 4. vMenu — το asset filename περιέχει version number
#    (π.χ. vMenu-3.8.20.zip), οπότε δεν υπάρχει σταθερό "latest/download/vMenu.zip".
#    Βρίσκουμε το πραγματικό URL μέσω του GitHub API.
# ---------------------------------------------------
if [ ! -d "$STANDALONE_DIR/vMenu" ]; then
    info "Ψάχνω το τελευταίο vMenu release asset..."
    VMENU_ZIP_URL="$(resolve_latest_zip_url "TomGrobbe/vMenu")"
    # Σημείωση: το folder ΠΡΕΠΕΙ να λέγεται ακριβώς "vMenu" (case sensitive) —
    # το ίδιο το resource ελέγχει το όνομα του φακέλου του στο runtime και
    # αρνείται να λειτουργήσει σωστά αν δεν ταιριάζει.
    install_resource "$VMENU_ZIP_URL" "$STANDALONE_DIR" "vMenu" "no"
else
    info "Το vMenu υπάρχει ήδη στο $STANDALONE_DIR — παραλείπεται."
fi

# ---------------------------------------------------
# 5. spawnmanager — default FiveM system resource, δεν διανέμεται ως GitHub
#    Release .zip (είναι μέρος του citizenfx/cfx-server-data repo), οπότε
#    κατεβάζουμε τα raw αρχεία απευθείας αντί να χρησιμοποιήσουμε install_resource.
#    Το qbx_core καλεί exports.spawnmanager:spawnPlayer(...) κατά το character
#    load — χωρίς αυτό ο client κολλάει σε μαύρη οθόνη.
# ---------------------------------------------------
SPAWNMANAGER_DIR="$STANDALONE_DIR/spawnmanager"
if [ -d "$SPAWNMANAGER_DIR" ]; then
    info "Το spawnmanager υπάρχει ήδη στο $STANDALONE_DIR — παραλείπεται."
else
    info "Κατεβάζω το spawnmanager..."
    mkdir -p "$SPAWNMANAGER_DIR"
    SPAWNMANAGER_BASE="https://raw.githubusercontent.com/citizenfx/cfx-server-data/master/resources/%5Bmanagers%5D/spawnmanager"
    if download "$SPAWNMANAGER_BASE/fxmanifest.lua" "$SPAWNMANAGER_DIR/fxmanifest.lua" \
        && download "$SPAWNMANAGER_BASE/spawnmanager.lua" "$SPAWNMANAGER_DIR/spawnmanager.lua" \
        && [ -s "$SPAWNMANAGER_DIR/fxmanifest.lua" ] && [ -s "$SPAWNMANAGER_DIR/spawnmanager.lua" ]; then
        success "spawnmanager κατέβηκε και εγκαταστάθηκε επιτυχώς στο $SPAWNMANAGER_DIR"
    else
        fail "Αποτυχία λήψης του spawnmanager"
        rm -rf "$SPAWNMANAGER_DIR"
        exit 1
    fi
fi

echo ""
success "Όλα τα third-party resources είναι έτοιμα."
info "Αντίγραψε το server.cfg.example σε server.cfg και συμπλήρωσε τα credentials σου πριν ξεκινήσεις τον server."
