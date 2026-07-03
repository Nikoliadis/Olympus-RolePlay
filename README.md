# Olympus RolePlay

FiveM roleplay server χτισμένος πάνω στο [QBox Framework](https://github.com/Qbox-project/qbx_core).

## Stack

| Component | Tech |
|---|---|
| Framework | [QBox (qbx_core)](https://github.com/Qbox-project/qbx_core) |
| Utility library | [ox_lib](https://github.com/overextended/ox_lib) |
| Database driver | [oxmysql](https://github.com/overextended/oxmysql) |
| Inventory | [ox_inventory](https://github.com/overextended/ox_inventory) |
| Database | MariaDB |
| Scripts | Lua (server/client), JavaScript (Discord bot) |

## Απαιτούμενα Dependencies

Τα resources του QBox, του Overextended, και το vMenu (`qbx_core`, `ox_lib`, `oxmysql`, `ox_inventory`, `vMenu`) είναι **third-party κώδικας τρίτων και δεν βρίσκονται μέσα στο repo** (βλ. `.gitignore` — οι φάκελοι `resources/[qbox]/`, `resources/[ox]/` και `resources/[standalone]/vMenu/` είναι εξαιρεμένοι, ακριβώς όπως το `node_modules/`). Κατεβαίνουν αυτόματα με το `install.sh` (δες παρακάτω).

Χρειάζεται επίσης να κατέβουν ξεχωριστά (χειροκίνητα):

- [FXServer artifacts](https://runtime.fivem.net/artifacts/fivem/build_server_windows/master/) (τελευταίο recommended build)
- [MariaDB](https://mariadb.org/download/) 10.6+
- [Node.js](https://nodejs.org/) 18+ (για το Discord bot)

### Εγκατάσταση Dependencies (`install.sh`)

Το script `install.sh` κατεβάζει αυτόματα τα **prebuilt releases (.zip)** των 5 third-party resources από το GitHub Releases του κάθε repo (όχι raw source clone — έτσι έρχονται έτοιμα τα built web UI assets):

```bash
./install.sh
```

Αυτό θα κατεβάσει, κάνει unzip, και σβήσει το .zip για:
- `qbx_core` → `resources/[qbox]/qbx_core`
- `ox_lib` → `resources/[ox]/ox_lib`
- `oxmysql` → `resources/[ox]/oxmysql`
- `ox_inventory` → `resources/[ox]/ox_inventory`
- `vMenu` → `resources/[standalone]/vMenu`

Ελέγχει πρώτα αν υπάρχει `curl` ή `wget` και `unzip`, και σταματάει με μήνυμα σφάλματος αν λείπουν. Αν κάποιο resource υπάρχει ήδη τοπικά, παραλείπεται (δεν το ξανακατεβάζει). Για το vMenu, επειδή το GitHub release asset του έχει version number στο filename (π.χ. `vMenu-3.8.20.zip`), το script βρίσκει αυτόματα το σωστό URL μέσω του GitHub API αντί να υποθέτει σταθερό filename.

> **Σημείωση:** το folder name `vMenu` (κεφαλαίο M) είναι υποχρεωτικό — το ίδιο το resource ελέγχει το όνομα του φακέλου του στο runtime και αρνείται να λειτουργήσει σωστά αν δεν ταιριάζει ακριβώς (case-sensitive).

## Δομή Φακέλων

```
Olympus-RolePlay/
├── config/
│   └── permissions.cfg  # vMenu permissions (staff/admin only) — execάρεται από το server.cfg
├── resources/
│   ├── [qbox]/          # QBox core resources (qbx_core, qbx_*)
│   ├── [ox]/            # Overextended resources (ox_lib, oxmysql, ox_inventory)
│   ├── [standalone]/    # Standalone resources τρίτων (vMenu, χωρίς framework dependency)
│   └── [custom]/        # Δικά μας custom scripts (jobs, gangs, HUD, κλπ)
├── discord-bot/         # JavaScript Discord bot
├── server.cfg           # Configuration του server (δεν committάρεται, βλ. server.cfg.example)
└── .gitignore
```

## Local Development Setup

1. **Clone το repository**
   ```bash
   git clone <repo-url>
   cd Olympus-RolePlay
   ```

2. **Κατέβασε τα FXServer artifacts** και βάλε τα στη ρίζα του project (εξαιρούνται από το git).

3. **Τρέξε το install script** για να κατέβουν τα third-party resources
   ```bash
   ./install.sh
   ```

4. **Στήσε τη βάση δεδομένων (MariaDB)**
   ```sql
   CREATE DATABASE olympus_roleplay CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   ```

5. **Αντίγραψε το config template**
   ```bash
   cp server.cfg.example server.cfg
   cp .env.example .env
   ```
   Συμπλήρωσε τα `server.cfg` και `.env` με τα δικά σου credentials (database connection string, license key, Discord bot token, κλπ). Τα αρχεία αυτά **δεν** committάρονται.

6. **Ξεκίνα τον server**
   ```bash
   FXServer.exe +exec server.cfg
   ```

7. **(Προαιρετικό) Discord bot**
   ```bash
   cd discord-bot
   npm install
   npm start
   ```

## Σειρά Εκκίνησης Resources

Η σωστή σειρά (βλ. `server.cfg`) είναι κρίσιμη λόγω dependencies:

1. `ox_lib`
2. `oxmysql`
3. `qbx_core`
4. `ox_inventory`
5. Υπόλοιπα `[qbox]`, `[standalone]`, `[custom]` resources

## vMenu (Staff/Admin only)

Το [vMenu](https://github.com/TomGrobbe/vMenu) είναι server-sided trainer/admin menu, εγκατεστημένο ως `resources/[standalone]/vMenu/` (κατεβαίνει αυτόματα μέσω `install.sh`).

Είναι κλειδωμένο ώστε **μόνο το `group.admin` να έχει πρόσβαση** — βλ. [`config/permissions.cfg`](config/permissions.cfg):

- `setr vmenu_menu_staff_only true` — κανένας παίκτης χωρίς το permission `vMenu.Staff` δεν μπορεί καν να ανοίξει το μενού.
- `add_ace group.admin "vMenu.Staff" allow` — δίνει στο group.admin πρόσβαση στο staff-only gate.
- `add_ace group.admin "vMenu.Everything" allow` — δίνει στο group.admin πλήρη πρόσβαση σε όλα τα submenus/features.
- Δεν δίνεται κανένα permission σε `builtin.everyone` ή άλλο group — όποιος δεν είναι στο `group.admin` δεν έχει καμία πρόσβαση.

Για να κάνεις κάποιον admin, πρόσθεσε το identifier του στο `server.cfg`:
```
add_principal identifier.<steam_ή_license_id> group.admin
```

Default keybind για άνοιγμα του μενού μέσα στο παιχνίδι: **M**.

> Αν θες να προσθέσεις δεύτερο επίπεδο (π.χ. `group.moderator` με περιορισμένα permissions), πρόσθεσε τα αντίστοιχα `add_ace group.moderator "vMenu.<Permission>" allow` στο `config/permissions.cfg` — δες τη [λίστα permissions του vMenu](https://github.com/TomGrobbe/vMenu/wiki/Permissions) για όλα τα διαθέσιμα nodes.

## Contributing

- Custom scripts πάνε στο `resources/[custom]/`.
- Μην κάνεις commit `.env`, `server.cfg`, ή οποιοδήποτε αρχείο με credentials — χρησιμοποίησε τα `.example` templates.
