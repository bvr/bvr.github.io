-- --------------------------------------------------------
-- Host:                         fctoolsbrno
-- Server version:               5.6.25-log - MySQL Community Server (GPL)
-- Server OS:                    Win64
-- HeidiSQL Version:             11.0.0.5919
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


-- Dumping database structure for copq
CREATE DATABASE IF NOT EXISTS `copq` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `copq`;

-- Dumping structure for table copq.group
CREATE TABLE IF NOT EXISTS `group` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `name` varchar(200) NOT NULL COMMENT 'Team/Group name',
  `always_visible` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Should be always visible',
  `active` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Active entry',
  `parent_id` int(11) DEFAULT NULL COMMENT 'Parent team/person',
  PRIMARY KEY (`id`),
  KEY `FK_group_group` (`parent_id`),
  CONSTRAINT `FK_group_group` FOREIGN KEY (`parent_id`) REFERENCES `group` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=198 DEFAULT CHARSET=utf8;

-- Data exporting was unselected.

-- Dumping structure for table copq.rework
CREATE TABLE IF NOT EXISTS `rework` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `date` datetime NOT NULL COMMENT 'When rework happened',
  `program` varchar(256) NOT NULL COMMENT 'Program (C919, etc)',
  `source` varchar(150) NOT NULL COMMENT 'Identification of the source (e.g. packet)',
  `hours` decimal(10,2) NOT NULL COMMENT 'How much',
  `penalty_hours` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT 'Penalty hours for re-review packets',
  `group_id` int(11) NOT NULL COMMENT 'Person/Group responsible',
  PRIMARY KEY (`id`),
  UNIQUE KEY `source` (`source`),
  KEY `FK_rework_group` (`group_id`),
  CONSTRAINT `FK_rework_group` FOREIGN KEY (`group_id`) REFERENCES `group` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=99677 DEFAULT CHARSET=utf8;

-- Data exporting was unselected.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
