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

Τα resources του QBox και του Overextended (`qbx_core`, `ox_lib`, `oxmysql`, `ox_inventory`) είναι **third-party κώδικας τρίτων και δεν βρίσκονται μέσα στο repo** (βλ. `.gitignore` — οι φάκελοι `resources/[qbox]/` και `resources/[ox]/` είναι εξαιρεμένοι, ακριβώς όπως το `node_modules/`). Κατεβαίνουν αυτόματα με το `install.sh` (δες παρακάτω).

Χρειάζεται επίσης να κατέβουν ξεχωριστά (χειροκίνητα):

- [FXServer artifacts](https://runtime.fivem.net/artifacts/fivem/build_server_windows/master/) (τελευταίο recommended build)
- [MariaDB](https://mariadb.org/download/) 10.6+
- [Node.js](https://nodejs.org/) 18+ (για το Discord bot)

### Εγκατάσταση Dependencies (`install.sh`)

Το script `install.sh` κατεβάζει αυτόματα με `git clone` τα 4 βασικά third-party resources στη σωστή θέση:

```bash
./install.sh
```

Αυτό θα κάνει clone:
- `qbx_core` → `resources/[qbox]/qbx_core`
- `ox_lib` → `resources/[ox]/ox_lib`
- `oxmysql` → `resources/[ox]/oxmysql`
- `ox_inventory` → `resources/[ox]/ox_inventory`

Ελέγχει πρώτα αν το `git` είναι εγκατεστημένο και σταματάει με μήνυμα σφάλματος αν λείπει. Αν κάποιο resource υπάρχει ήδη τοπικά, παραλείπεται (δεν το ξανακατεβάζει).

> **Σημείωση:** το `ox_lib`, το `oxmysql` και το `ox_inventory` έχουν build step (web UI) που δεν περιλαμβάνεται στο raw source clone. Αν δεις σφάλματα τύπου `Unable to load UI` ή `module not found` όταν τρέξεις τον server, κατέβασε τα prebuilt `.zip` από τη σελίδα **Releases** του κάθε repo (π.χ. `https://github.com/overextended/ox_lib/releases/latest`) και αντικατέστησε τον αντίστοιχο φάκελο.

## Δομή Φακέλων

```
Olympus-RolePlay/
├── resources/
│   ├── [qbox]/          # QBox core resources (qbx_core, qbx_*)
│   ├── [ox]/            # Overextended resources (ox_lib, oxmysql, ox_inventory)
│   ├── [standalone]/    # Standalone resources τρίτων (χωρίς framework dependency)
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

## Contributing

- Custom scripts πάνε στο `resources/[custom]/`.
- Μην κάνεις commit `.env`, `server.cfg`, ή οποιοδήποτε αρχείο με credentials — χρησιμοποίησε τα `.example` templates.
