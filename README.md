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
| Target/interaction | [ox_target](https://github.com/overextended/ox_target), [qb-target](https://github.com/qbcore-framework/qb-target), [PolyZone](https://github.com/mkafrin/PolyZone) |
| Jobs / properties | qbx_garages, qbx_vehicleshop, qbx_taxijob, qbx_mechanicjob, qbx_properties, qbx_police, qbx_ambulancejob, qbx_truckrobbery, qbx_phone (όλα [Qbox-project](https://github.com/Qbox-project)) |
| Database | MariaDB |
| Scripts | Lua (server/client), JavaScript (Discord bot) |

## Απαιτούμενα Dependencies

Όλα τα third-party resources είναι **κώδικας τρίτων και δεν βρίσκονται μέσα στο repo** (βλ. `.gitignore` — ολόκληροι οι φάκελοι `resources/[qbox]/` και `resources/[ox]/` είναι εξαιρεμένοι, καθώς και συγκεκριμένα third-party resources μέσα στο `resources/[standalone]/`, ακριβώς όπως το `node_modules/`). Κατεβαίνουν αυτόματα με το `install.sh` (δες παρακάτω).

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
- `qbx_garages` → `resources/[qbox]/qbx_garages`
- `qbx_truckrobbery` → `resources/[qbox]/qbx_truckrobbery`
- `ox_lib` → `resources/[ox]/ox_lib`
- `oxmysql` → `resources/[ox]/oxmysql`
- `ox_inventory` → `resources/[ox]/ox_inventory`
- `ox_target` → `resources/[ox]/ox_target`
- `illenium-appearance` → `resources/[standalone]/illenium-appearance`
- `vMenu` → `resources/[standalone]/vMenu`
- `PolyZone` → `resources/[standalone]/PolyZone`
- `spawnmanager` → `resources/[standalone]/spawnmanager` (raw αρχεία από το [citizenfx/cfx-server-data](https://github.com/citizenfx/cfx-server-data), όχι release .zip — δες παρακάτω γιατί είναι απαραίτητο)

Ελέγχει πρώτα αν υπάρχει `curl` ή `wget` και `unzip`, και σταματάει με μήνυμα σφάλματος αν λείπουν. Αν κάποιο resource υπάρχει ήδη τοπικά, παραλείπεται (δεν το ξανακατεβάζει). Για το vMenu, επειδή το GitHub release asset του έχει version number στο filename (π.χ. `vMenu-3.8.20.zip`), το script βρίσκει αυτόματα το σωστό URL μέσω του GitHub API αντί να υποθέτει σταθερό filename.

> **Σημείωση:** το folder name `vMenu` (κεφαλαίο M) είναι υποχρεωτικό — το ίδιο το resource ελέγχει το όνομα του φακέλου του στο runtime και αρνείται να λειτουργήσει σωστά αν δεν ταιριάζει ακριβώς (case-sensitive).

> **Σημαντικό: `spawnmanager` είναι απαραίτητο, όχι προαιρετικό.** Το `qbx_core` καλεί `exports.spawnmanager:spawnPlayer(...)` όταν φορτώνει χαρακτήρας. Χωρίς αυτό το resource, ο client κολλάει σε **μαύρη οθόνη** στο character select (το σφάλμα καταπίνεται σιωπηλά από ένα `pcall`, και ο client μπαίνει σε ατέρμονο loop περιμένοντας ένα `DoScreenFadeIn` που ποτέ δεν έρχεται). Πρέπει να είναι `ensure`d **πριν** το `qbx_core` στο `server.cfg`.

### Qbox job/property resources χωρίς GitHub release (git clone)

Τα παρακάτω resources **δεν έχουν κανένα GitHub release** (μόνο source code) — το `install.sh` τα κατεβάζει με `git clone --depth 1` αντί για .zip. Επιβεβαιώθηκε ότι δεν έχουν build step (δεν χρησιμοποιούν `web/dist`/webpack), οπότε το raw source τρέχει κανονικά:

- `qbx_mechanicjob` → `resources/[qbox]/qbx_mechanicjob`
- `qbx_properties` → `resources/[qbox]/qbx_properties`
- `qbx_taxijob` → `resources/[qbox]/qbx_taxijob`
- `qbx_vehicleshop` → `resources/[qbox]/qbx_vehicleshop`
- `qbx_ambulancejob` → `resources/[qbox]/qbx_ambulancejob`
- `qbx_phone` → `resources/[qbox]/qbx_phone`
- `qbx_police` → `resources/[qbox]/qbx_police` (το repo `qbx_policejob` έχει μετονομαστεί σε `qbx_police` upstream)
- `qb-target` → `resources/[standalone]/qb-target`

Χρειάζεται `git` εγκατεστημένο για αυτά — το script το ελέγχει και σταματάει με σαφές μήνυμα αν λείπει.

### Resources που ΔΕΝ κατεβαίνουν αυτόματα

- **`screenshot-basic`** ([citizenfx/screenshot-basic](https://github.com/citizenfx/screenshot-basic)) — δεν έχει GitHub release **και** το raw source απαιτεί webpack build (`dist/client.js`, `dist/server.js` δεν υπάρχουν committed στο repo). Αν το χρειάζεσαι, θα πρέπει να το κλωνοποιήσεις και να τρέξεις `yarn && yarn build` μόνος σου, ή να βρεις ένα fork με prebuilt release.
- **`qbx_input`, `qbx_menu`, `qbx_interact`** — δεν βρέθηκαν resources με αυτά τα ονόματα κάτω από το [Qbox-project](https://github.com/Qbox-project) στο GitHub (ούτε αλλού ως αναγνωρίσιμα, νόμιμα forks). Αν πρόκειται για πραγματικά resources με διαφορετικό owner/όνομα, στείλε το σωστό link και θα τα προσθέσουμε.

## Δομή Φακέλων

```
Olympus-RolePlay/
├── config/
│   └── permissions.cfg  # vMenu permissions (staff/admin only) — execάρεται από το server.cfg
├── resources/
│   ├── [qbox]/          # QBox core resources (qbx_core, qbx_*)
│   ├── [ox]/            # Overextended resources (ox_lib, oxmysql, ox_inventory)
│   ├── [standalone]/    # Standalone resources τρίτων (vMenu, spawnmanager, illenium-appearance, PolyZone, qb-target, χωρίς framework dependency)
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
8. `ox_target`
9. `PolyZone`, `qb-target` (χρειάζονται από τα qbx_* job resources παρακάτω)
10. `qbx_garages`, `qbx_vehicleshop`, `qbx_taxijob`, `qbx_mechanicjob`, `qbx_properties`, `qbx_police`, `qbx_ambulancejob`, `qbx_truckrobbery`, `qbx_phone`
11. Υπόλοιπα `[qbox]`, `[standalone]`, `[custom]` resources

## Spawn & Character Appearance

Η ροή δημιουργίας/φόρτωσης χαρακτήρα:

- **Νέος χαρακτήρας:** custom NUI δημιουργίας χαρακτήρα + cinematic spawn στο Los Santos Job Center (`-169.0, -1640.0, 33.0`) μέσω του δικού μας `resources/[custom]/olympus_spawn` (δες παρακάτω). Το `defaultSpawn` του qbx_core (`resources/[qbox]/qbx_core/config/shared.lua`) είναι ρυθμισμένο στις ίδιες coords ως γενικό fallback. Αμέσως μετά ανοίγει αυτόματα το outfit creation menu του `illenium-appearance` (event `qb-clothes:client:CreateFirstCharacter`).
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
