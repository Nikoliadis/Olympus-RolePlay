#!/usr/bin/env bash
#
# Olympus RolePlay — install.sh
# Κατεβάζει τα third-party resources (QBox + ox_*) που δεν είναι committed στο repo.
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
# 1. Έλεγχος ότι υπάρχει git
# ---------------------------------------------------
if ! command -v git >/dev/null 2>&1; then
    fail "Το git δεν είναι εγκατεστημένο. Κατέβασέ το από https://git-scm.com/downloads και ξανατρέξε το script."
    exit 1
fi
success "Το git είναι εγκατεστημένο ($(git --version))"

mkdir -p "$QBOX_DIR" "$OX_DIR"

# ---------------------------------------------------
# 2. Βοηθητική συνάρτηση clone
#    clone_resource <repo_url> <target_dir> <resource_name>
# ---------------------------------------------------
clone_resource() {
    local repo_url="$1"
    local target_dir="$2"
    local name="$3"

    if [ -d "$target_dir/$name" ]; then
        info "Το $name υπάρχει ήδη στο $target_dir — παραλείπεται (διέγραψέ το χειροκίνητα αν θες re-download)."
        return 0
    fi

    info "Κατεβάζω το $name..."
    if git clone --depth 1 "$repo_url" "$target_dir/$name" > /dev/null 2>&1; then
        rm -rf "$target_dir/$name/.git"
        success "$name κατέβηκε επιτυχώς στο $target_dir/$name"
    else
        fail "Αποτυχία λήψης του $name από $repo_url"
        exit 1
    fi
}

# ---------------------------------------------------
# 3. Λήψη resources
# ---------------------------------------------------
clone_resource "https://github.com/Qbox-project/qbx_core.git"      "$QBOX_DIR" "qbx_core"
clone_resource "https://github.com/overextended/ox_lib.git"        "$OX_DIR"   "ox_lib"
clone_resource "https://github.com/overextended/oxmysql.git"       "$OX_DIR"   "oxmysql"
clone_resource "https://github.com/overextended/ox_inventory.git"  "$OX_DIR"   "ox_inventory"

echo ""
success "Όλα τα third-party resources είναι έτοιμα."
info "Σημείωση: το ox_lib, το oxmysql και το ox_inventory χρειάζονται built web assets."
info "Αν δεις σφάλματα τύπου 'Unable to load UI' ή 'module not found', κατέβασε τα prebuilt release .zip"
info "από τη σελίδα Releases του κάθε repo αντί για clone του source."
info "Αντίγραψε το server.cfg.example σε server.cfg και συμπλήρωσε τα credentials σου πριν ξεκινήσεις τον server."
