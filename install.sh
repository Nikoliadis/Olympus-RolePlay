#!/usr/bin/env bash
#
# Olympus RolePlay — install.sh
# Κατεβάζει τα prebuilt releases (.zip) των third-party resources (QBox + ox_*)
# που δεν είναι committed στο repo.
#
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QBOX_DIR="$ROOT_DIR/resources/[qbox]"
OX_DIR="$ROOT_DIR/resources/[ox]"

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

mkdir -p "$QBOX_DIR" "$OX_DIR"

# ---------------------------------------------------
# 2. Βοηθητική συνάρτηση λήψης prebuilt release .zip
#    install_resource <owner/repo> <target_dir> <resource_name>
# ---------------------------------------------------
install_resource() {
    local repo="$1"
    local target_dir="$2"
    local name="$3"
    local zip_url="https://github.com/$repo/releases/latest/download/$name.zip"
    local zip_path="$target_dir/$name.zip"
    local extract_dir="$target_dir/.${name}_extract"

    if [ -d "$target_dir/$name" ]; then
        info "Το $name υπάρχει ήδη στο $target_dir — παραλείπεται (διέγραψέ το χειροκίνητα αν θες re-download)."
        return 0
    fi

    info "Κατεβάζω το $name (prebuilt release)..."
    if ! download "$zip_url" "$zip_path"; then
        fail "Αποτυχία λήψης του $name από $zip_url"
        exit 1
    fi

    if [ ! -s "$zip_path" ]; then
        fail "Το $name.zip κατέβηκε άδειο — έλεγξε ότι το repo $repo έχει release με asset '$name.zip'."
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

    # Τα releases του overextended/qbox περιέχουν έναν φάκελο <name>/ μέσα στο zip.
    if [ -d "$extract_dir/$name" ]; then
        mv "$extract_dir/$name" "$target_dir/$name"
    else
        # Fallback: αν το zip δεν έχει wrapper folder, μετακίνησε ολόκληρο το extract_dir.
        mv "$extract_dir" "$target_dir/$name"
        extract_dir=""
    fi

    rm -f "$zip_path"
    [ -n "$extract_dir" ] && rm -rf "$extract_dir"

    success "$name κατέβηκε και εγκαταστάθηκε επιτυχώς στο $target_dir/$name"
}

# ---------------------------------------------------
# 3. Λήψη resources (prebuilt releases)
# ---------------------------------------------------
install_resource "Qbox-project/qbx_core"     "$QBOX_DIR" "qbx_core"
install_resource "overextended/ox_lib"       "$OX_DIR"   "ox_lib"
install_resource "overextended/oxmysql"      "$OX_DIR"   "oxmysql"
install_resource "overextended/ox_inventory" "$OX_DIR"   "ox_inventory"

echo ""
success "Όλα τα third-party resources είναι έτοιμα."
info "Αντίγραψε το server.cfg.example σε server.cfg και συμπλήρωσε τα credentials σου πριν ξεκινήσεις τον server."
