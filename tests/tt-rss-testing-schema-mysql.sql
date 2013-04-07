-- Server version: 5.5.29
-- PHP Version: 5.4.6-1ubuntu1.2

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: 'tt-rss-testing'
--

-- --------------------------------------------------------

--
-- Table structure for table 'DbFunctionsTest_subtable'
--

DROP TABLE IF EXISTS DbFunctionsTest_subtable;
CREATE TABLE IF NOT EXISTS DbFunctionsTest_subtable (
  a_key int(11) NOT NULL,
  a_fkey int(11) NOT NULL,
  a_varchar varchar(255) COLLATE utf8_bin NOT NULL DEFAULT '',
  PRIMARY KEY (a_key),
  KEY a_fkey (a_fkey)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- RELATIONS FOR TABLE DbFunctionsTest_subtable:
--   a_fkey
--       DbFunctionsTest_table -> a_key
--

-- --------------------------------------------------------

--
-- Table structure for table 'DbFunctionsTest_table'
--

DROP TABLE IF EXISTS DbFunctionsTest_table;
CREATE TABLE IF NOT EXISTS DbFunctionsTest_table (
  a_key int(11) NOT NULL,
  a_varchar varchar(255) COLLATE utf8_bin NOT NULL DEFAULT '',
  a_integer int(11) NOT NULL DEFAULT '0',
  a_datetime datetime DEFAULT NULL,
  a_bool tinyint(1) NOT NULL DEFAULT '0',
  a_text text COLLATE utf8_bin,
  PRIMARY KEY (a_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
