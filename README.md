# Olympus RolePlay

FiveM roleplay server χτισμένος πάνω στο [QBox Framework](https://github.com/Qbox-project/qbx_core).

## Stack

| Component | Tech |
|---|---|
| Framework | [QBox (qbx_core)](https://github.com/Qbox-project/qbx_core) |
| Utility library | [ox_lib](https://github.com/overextended/ox_lib) |
| Database driver | [oxmysql](https://github.com/overextended/oxmysql) |
| Inventory | [ox_inventory](https://github.com/overextended/ox_inventory) |
| Spawn selection | [qbx_spawn](https://github.com/Qbox-project/qbx_spawn) |
| Character appearance/outfits | [illenium-appearance](https://github.com/iLLeniumStudios/illenium-appearance) |
| Database | MariaDB |
| Scripts | Lua (server/client), JavaScript (Discord bot) |

## Απαιτούμενα Dependencies

Όλα τα third-party resources (`qbx_core`, `qbx_spawn`, `ox_lib`, `oxmysql`, `ox_inventory`, `illenium-appearance`, `vMenu`, `spawnmanager`) είναι **κώδικας τρίτων και δεν βρίσκονται μέσα στο repo** (βλ. `.gitignore` — οι φάκελοι `resources/[qbox]/` και `resources/[ox]/`, καθώς και τα επιμέρους `resources/[standalone]/vMenu/`, `resources/[standalone]/spawnmanager/`, `resources/[standalone]/illenium-appearance/`, είναι εξαιρεμένοι, ακριβώς όπως το `node_modules/`). Κατεβαίνουν αυτόματα με το `install.sh` (δες παρακάτω).

Χρειάζεται επίσης να κατέβουν ξεχωριστά (χειροκίνητα):

- [FXServer artifacts](https://runtime.fivem.net/artifacts/fivem/build_server_windows/master/) (τελευταίο recommended build)
- [MariaDB](https://mariadb.org/download/) 10.6+
- [Node.js](https://nodejs.org/) 18+ (για το Discord bot)

### Εγκατάσταση Dependencies (`install.sh`)

Το script `install.sh` κατεβάζει αυτόματα τα **prebuilt releases (.zip)** των third-party resources από το GitHub Releases του κάθε repo (όχι raw source clone — έτσι έρχονται έτοιμα τα built web UI assets):

```bash
./install.sh
```

Αυτό θα κατεβάσει, κάνει unzip, και σβήσει το .zip για:
- `qbx_core` → `resources/[qbox]/qbx_core`
- `qbx_spawn` → `resources/[qbox]/qbx_spawn`
- `ox_lib` → `resources/[ox]/ox_lib`
- `oxmysql` → `resources/[ox]/oxmysql`
- `ox_inventory` → `resources/[ox]/ox_inventory`
- `illenium-appearance` → `resources/[standalone]/illenium-appearance`
- `vMenu` → `resources/[standalone]/vMenu`
- `spawnmanager` → `resources/[standalone]/spawnmanager` (raw αρχεία από το [citizenfx/cfx-server-data](https://github.com/citizenfx/cfx-server-data), όχι release .zip — δες παρακάτω γιατί είναι απαραίτητο)

Ελέγχει πρώτα αν υπάρχει `curl` ή `wget` και `unzip`, και σταματάει με μήνυμα σφάλματος αν λείπουν. Αν κάποιο resource υπάρχει ήδη τοπικά, παραλείπεται (δεν το ξανακατεβάζει). Για το vMenu, επειδή το GitHub release asset του έχει version number στο filename (π.χ. `vMenu-3.8.20.zip`), το script βρίσκει αυτόματα το σωστό URL μέσω του GitHub API αντί να υποθέτει σταθερό filename.

> **Σημείωση:** το folder name `vMenu` (κεφαλαίο M) είναι υποχρεωτικό — το ίδιο το resource ελέγχει το όνομα του φακέλου του στο runtime και αρνείται να λειτουργήσει σωστά αν δεν ταιριάζει ακριβώς (case-sensitive).

> **Σημαντικό: `spawnmanager` είναι απαραίτητο, όχι προαιρετικό.** Το `qbx_core` καλεί `exports.spawnmanager:spawnPlayer(...)` όταν φορτώνει χαρακτήρας. Χωρίς αυτό το resource, ο client κολλάει σε **μαύρη οθόνη** στο character select (το σφάλμα καταπίνεται σιωπηλά από ένα `pcall`, και ο client μπαίνει σε ατέρμονο loop περιμένοντας ένα `DoScreenFadeIn` που ποτέ δεν έρχεται). Πρέπει να είναι `ensure`d **πριν** το `qbx_core` στο `server.cfg`.

## Δομή Φακέλων

```
Olympus-RolePlay/
├── config/
│   └── permissions.cfg  # vMenu permissions (staff/admin only) — execάρεται από το server.cfg
├── resources/
│   ├── [qbox]/          # QBox core resources (qbx_core, qbx_*)
│   ├── [ox]/            # Overextended resources (ox_lib, oxmysql, ox_inventory)
│   ├── [standalone]/    # Standalone resources τρίτων (vMenu, spawnmanager, illenium-appearance, χωρίς framework dependency)
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
   Το `qbx_core` δημιουργεί μόνο του τους περισσότερους πίνακες του στην πρώτη εκκίνηση (μέσω `resources/[qbox]/qbx_core/qbx_core.sql`). Τρέξε επιπλέον το [`database/extra_tables.sql`](database/extra_tables.sql) για πίνακες που δεν καλύπτονται από αυτό (π.χ. `playerskins`, που διαβάζεται σε κάθε character load αλλά δεν δημιουργείται από ξεχωριστό appearance resource):
   ```bash
   mysql -u <user> -p olympus_roleplay < database/extra_tables.sql
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
3. `spawnmanager` (πρέπει να τρέχει πριν το qbx_core το καλέσει κατά το character spawn)
4. `illenium-appearance` (character appearance/outfits)
5. `qbx_spawn` (spawn location picker)
6. `qbx_core`
7. `ox_inventory`
8. Υπόλοιπα `[qbox]`, `[standalone]`, `[custom]` resources

## Spawn & Character Appearance

Η ροή δημιουργίας/φόρτωσης χαρακτήρα:

- **Νέος χαρακτήρας:** μετά τη δημιουργία, ο παίκτης κάνει spawn στο `defaultSpawn` του qbx_core (`resources/[qbox]/qbx_core/config/shared.lua`) — ρυθμισμένο στο **Legion Square** (κλασικό Job Center, coords `195.17, -933.77, 29.7, 144.5`). Αμέσως μετά ανοίγει αυτόματα το outfit creation menu του `illenium-appearance` (event `qb-clothes:client:CreateFirstCharacter`).
- **Υπάρχων χαρακτήρας:** στο "Play" από το character select, ανοίγει το `qbx_spawn` UI με επιλογές τοποθεσίας — **Legion Square** (Job Center), **Paleto Bay**, **Motels**, ή η τελευταία θέση αποσύνδεσης (ρύθμιση στο `resources/[qbox]/qbx_spawn/config/client.lua`).
- Το `illenium-appearance` επίσης χειρίζεται clothing shops/barber/tattoo (μέσω radial/target menu) και αποθηκεύει outfits στους πίνακες `playerskins` (ενεργή εμφάνιση) και `player_outfits` (αποθηκευμένα σετ) — δες [`database/extra_tables.sql`](database/extra_tables.sql).

> **Σημείωση για starter items:** το `qbx_core` default config δίνει από προεπιλογή `id_card`/`driver_license` ως starter items, κάτι που απαιτεί το resource `qbx_idcard` (+ εξάρτηση `MugShotBase64`). Δεν τα έχουμε εγκαταστήσει — τα αφαιρέσαμε από το `config/shared.lua` starterItems (μένει μόνο `phone`) ώστε να μην κρασάρει η δημιουργία χαρακτήρα. Πρόσθεσέ τα ξανά αν εγκαταστήσεις το `qbx_idcard`.

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
