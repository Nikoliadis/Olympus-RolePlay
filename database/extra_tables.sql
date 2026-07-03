-- Olympus RolePlay — extra tables δεν καλύπτονται από το qbx_core.sql
--
-- Τρέξε αυτό ΜΕΤΑ το resources/[qbox]/qbx_core/qbx_core.sql κατά το setup:
--   mysql -u <user> -p <database> < database/extra_tables.sql

-- qbx_core (server/storage/players.lua) διαβάζει τον ενεργό σκελετό/εμφάνιση
-- του χαρακτήρα από τον πίνακα `playerskins` σε κάθε character load
-- (SELECT * FROM playerskins WHERE citizenid = ? AND active = 1), αλλά ο
-- πίνακας δεν περιλαμβάνεται στο qbx_core.sql — κανονικά τον δημιουργεί ένα
-- ξεχωριστό appearance resource (π.χ. illenium-appearance). Μέχρι να
-- εγκατασταθεί τέτοιο resource, ο πίνακας πρέπει να υπάρχει έστω άδειος
-- ώστε το query να μην αποτυγχάνει. Schema βάσει του qbx_core PlayerSkin type
-- (resources/[qbox]/qbx_core/types.lua): citizenid, model, skin, active.
CREATE TABLE IF NOT EXISTS `playerskins` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `citizenid` VARCHAR(50) NOT NULL,
  `model` VARCHAR(60) NOT NULL,
  `skin` LONGTEXT NOT NULL,
  `active` TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`),
  CONSTRAINT `fk_playerskins_citizenid` FOREIGN KEY (`citizenid`) REFERENCES `players` (`citizenid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
