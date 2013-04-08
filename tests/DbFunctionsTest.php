<?php // DbFunctionsTest.php - Tests for functions in db.php

require_once "PHPUnit/Extensions/Database/TestCase.php";

// Try to trick db.php into loading config.php from this directory
set_include_path(dirname(__FILE__) . PATH_SEPARATOR . get_include_path());

require_once "include/db.php";

class DbFuctionsTest extends PHPUnit_Extensions_Database_TestCase
{
	// only instantiate pdo once for test clean-up/fixture load
	static private $pdo = null;

	// only instantiate PHPUnit_Extensions_Database_DB_IDatabaseConnection 
	// once per test
	private $conn = null;

	/**
	 * Get the testing framework's connection to the test database
	 * Connection parameters are defined in phpunit.xml or phpunit.xml.dist
	 *
	 * @return PHPUnit_Extensions_Database_DB_IDatabaseConnection
	 */
	public function getConnection()
	{
		if ($this->conn === null) {
			if (self::$pdo == null) {
				switch ($GLOBALS['TEST_DB_TYPE']) {
					//TODO: PgSQL support
				default:
					// Default to mysql
					$dsn = 'mysql:' . implode(array(
						"host=" . $GLOBALS['TEST_DB_HOST'],
						"port=" . $GLOBALS['TEST_DB_PORT'],
						"dbname=" . $GLOBALS['TEST_DB_DBNAME'],
					),';');
				}
				self::$pdo = new PDO( $dsn,
					$GLOBALS['TEST_DB_USER'], 
					$GLOBALS['TEST_DB_PASSWD'] );
			}
			$this->conn = 
				$this->createDefaultDBConnection(self::$pdo, 
				$GLOBALS['TEST_DB_DBNAME']);
		}

		return $this->conn;
	}

	/**
	 * Create test data from XML file
	 *
	 * @return PHPUnit_Extensions_Database_DataSet_IDataSet
	 */
	public function getDataSet()
	{
		return $this->createMySQLXMLDataSet(
			preg_replace('/.php$/', 'Data.xml', __FILE__));
	}

	/**
	 * Setup testing fixture
	 */
	protected function setUp() 
	{
		parent::setUp();
		// Overrite config.php defines here, luckily db.php doesn't use 
		// many of them
		@define('DB_TYPE', $GLOBALS['TEST_DB_TYPE']);
		@define('DB_PORT', $GLOBALS['TEST_DB_PORT']);
	}

	///// Testing code starts here /////
	
	public function testDbConnect()
	{
		$dblink = db_connect($GLOBALS['TEST_DB_HOST'], 
			$GLOBALS['TEST_DB_USER'], $GLOBALS['TEST_DB_PASSWD'], 
			$GLOBALS['TEST_DB_DBNAME']);
		$this->assertNotNull($dblink);
		return $dblink;
	}

	/**
	 * @depends testDbConnect
	 * @dataProvider stringsToEscape
	 */
	public function testDbEscapeString($str, $escaped, $unstripped, $dblink)
	{
		$this->assertEquals(db_escape_string($dblink, $str), $escaped);
		$this->assertEquals(db_escape_string($dblink, $str, false), $unstripped);
	}

	/**
	 * @depends testDbConnect
	 * @dataProvider stringsToEscape
	 */
	public function testDbUnescapeString($str, $escaped, $unstripped, $dblink)
	{
		$this->assertEquals(db_unescape_string($unstripped), $str);
	}

	public function stringsToEscape()
	{
		return array(
			//    string        escaped      unstripped
			array('abcde',	    'abcde',     'abcde'        ),
			array('ab\'cde',    'ab\\\'cde', 'ab\\\'cde'    ),
			array('ab<i>cde',   'abcde',     'ab<i>cde'     ),
			array('ab<i>cd\'e', 'abcd\\\'e', 'ab<i>cd\\\'e' ),
		);
	}


	/**
	 * @depends testDbConnect
	 */
	public function testDbQuerySelect($dblink)
	{
		$sql = "SELECT * FROM DbFunctionsTest_table";
		$result = db_query($dblink, $sql);
		$this->assertNotNull($result);
		return $result;
	}

	/**
	 * @depends testDbQuerySelect
	 * @dataProvider tableData
	 */
	public function testDbFetchAssoc($row_num, $expected_row, $result)
	{
		$fetched_row = db_fetch_assoc($result);
		$this->assertEquals(array_keys($expected_row), array_keys($fetched_row));
		foreach($fetched_row as $fetched_field => $fetched_value) {
			$expected_value = $expected_row[$fetched_field];
			if (is_null($expected_value)) {
				// NULLs will not be of type 'string' so can't 
				// assert that
				$this->assertNull($fetched_value);
			} else {
				$this->assertInternalType('string', $fetched_value);
				$this->assertEquals($expected_value, $fetched_value);
			}
		}
	}
	public function tableData()
	{
		$table = $this->getConnection()->createDataSet()->getTable('DbFunctionsTest_table');
		$data = array();
		$rows = $table->getRowCount();
		for($i = 0; $i < $rows; ++$i) {
			$data[] = array($i, $table->getRow($i));
		}
		return $data;
	}

	/**
	 * @depends testDbQuerySelect
	 */
	public function testDbNumRows($result)
	{
		$this->assertEquals($this->getConnection()->getRowCount('DbFunctionsTest_table'), 
			db_num_rows($result));
	}

	/**
	 * @depends testDbQuerySelect
	 * @dataProvider tableData
	 */
	public function testDbFetchResult($row_num, $expected_row, $result)
	{
		foreach(array_values($expected_row) as $i => $expected_value) {
			$value = db_fetch_result($result, $row_num, $i);
			$this->assertEquals($expected_value, $value);
		}
	}
}

?>
