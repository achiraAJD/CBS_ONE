<?php
ini_set('max_execution_time', '0'); 

$db_username = "sabn";
$db_password = "sabnxpt_bn";
$db = "odbc:SABNXPT";
$oraconn = new PDO($db,$db_username,$db_password);

$db_username = "WebUser";
$db_password = "1FKidCv3!";
$msconn = new PDO("sqlsrv:Server=AGDCBSDATMSQL01; Database=SABNXPT", $db_username, $db_password);


$selectstmt = $oraconn->query("SELECT * FROM ADDRESS WHERE ADDRESS_ID = 34486");

while ($select = $selectstmt->fetch(PDO::FETCH_ASSOC)){
	foreach ($select as $key => $value) {
		$yymmdd = "/^\d{4}\-(0[1-9]|1[012])\-(0[1-9]|[12][0-9]|3[01])$/";
		if(preg_match($yymmdd, substr($value, 0, 10))) {
			if (substr($value,2,2) < 23) {
				$select[$key] = '20' . substr($value, 2);
			} else {
				$select[$key] = '19' . substr($value, 2);
			}
		}
	}
	$numColumns = sizeof($select);
	$insertstmt = $msconn->prepare("INSERT INTO ADDRESS (".implode(',', array_keys($select)).") VALUES (".implode(', ', array_fill(0,$numColumns,'?')).")");
	$insertstmt->execute(array_values($select));
	var_dump($insertstmt->errorInfo());
}

?>