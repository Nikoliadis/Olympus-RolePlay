-- Olympus RolePlay — extra tables δεν καλύπτονται από το qbx_core.sql
--
-- Τρέξε αυτό ΜΕΤΑ το resources/[qbox]/qbx_core/qbx_core.sql κατά το setup:
--   mysql -u <user> -p <database> < database/extra_tables.sql

-- qbx_core (server/storage/players.lua) διαβάζει τον ενεργό σκελετό/εμφάνιση
-- του χαρακτήρα από τον πίνακα `playerskins` σε κάθε character load
-- (SELECT * FROM playerskins WHERE citizenid = ? AND active = 1). Πλέον
-- χρησιμοποιείται ενεργά από το resources/[standalone]/illenium-appearance
-- (server/database/playerskins.lua) — schema συμβατό και με τα δύο
-- (βλ. illenium-appearance/sql/playerskins.sql & qbx_core/types.lua PlayerSkin).
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

-- illenium-appearance (server/database/playeroutfits.lua) αποθηκεύει εδώ τα
-- saved outfits του παίκτη (πολλαπλά ονομασμένα outfits ανά χαρακτήρα, όχι
-- μόνο το ενεργό skin). Schema από το επίσημο illenium-appearance/sql/player_outfits.sql.
CREATE TABLE IF NOT EXISTS `player_outfits` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `citizenid` VARCHAR(50) DEFAULT NULL,
  `outfitname` VARCHAR(50) NOT NULL DEFAULT '0',
  `model` VARCHAR(50) DEFAULT NULL,
  `props` VARCHAR(1000) DEFAULT NULL,
  `components` VARCHAR(1500) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `citizenid_outfitname_model` (`citizenid`, `outfitname`, `model`),
  KEY `citizenid` (`citizenid`),
  CONSTRAINT `fk_player_outfits_citizenid` FOREIGN KEY (`citizenid`) REFERENCES `players` (`citizenid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
