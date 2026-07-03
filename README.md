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

Πρέπει να κατέβουν ξεχωριστά (δεν περιλαμβάνονται στο repo) και να μπουν στο αντίστοιχο resource folder:

- [FXServer artifacts](https://runtime.fivem.net/artifacts/fivem/build_server_windows/master/) (τελευταίο recommended build)
- [qbx_core](https://github.com/Qbox-project/qbx_core) → `resources/[qbox]/`
- [ox_lib](https://github.com/overextended/ox_lib) → `resources/[ox]/`
- [oxmysql](https://github.com/overextended/oxmysql) → `resources/[ox]/`
- [ox_inventory](https://github.com/overextended/ox_inventory) → `resources/[ox]/`
- [MariaDB](https://mariadb.org/download/) 10.6+
- [Node.js](https://nodejs.org/) 18+ (για το Discord bot)

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

3. **Εγκατάστησε τα dependencies στο `resources/`** σύμφωνα με τη δομή παραπάνω (`ox_lib`, `oxmysql`, `qbx_core`, `ox_inventory`).

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
