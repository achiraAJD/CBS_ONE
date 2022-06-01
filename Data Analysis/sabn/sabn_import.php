<?php
ini_set('max_execution_time', '0'); 

$db_username = "sabn";
$db_password = "sabnxpt_bn";
$db = "odbc:SABNXPT";
$oraconn = new PDO($db,$db_username,$db_password);

$db_username = "WebUser";
$db_password = "1FKidCv3!";
$msconn = new PDO("sqlsrv:Server=AGDCBSDATMSQL01; Database=SABNXPT", $db_username, $db_password);

$stmt = $oraconn->query("
    SELECT *
    FROM user_tables
    ORDER BY TABLE_NAME ASC;
");

$tableNameArr = array('DOCUMENT_HISTORIES');
/*

*/
/*|| !in_array($row['TABLE_NAME'],$tableNameArr)*/

while ($row = $stmt->fetch(PDO::FETCH_ASSOC)){
    if (strpos($row['TABLE_NAME'], '=')) {
        continue;
    }

    //echo "<pre>";print_r($row);echo "</pre>";
    //if ($row['TABLE_NAME'] == 'FINANCIAL_ADJUSTMENTS') die();
    
    if($row['TABLE_NAME'] == 'ELECTRONIC_SIGNATURES'){
    //if(in_array($row['TABLE_NAME'],$tableNameArr)){
        $countstmt = $oraconn->query("SELECT COUNT(*) c FROM " . $row['TABLE_NAME']);
        $batch = 10000;
        
        while ($count = $countstmt->fetch(PDO::FETCH_ASSOC)){
            #echo  '<pre>';print_r($count);echo '</pre>';
            if($count['C'] > 0) {
                for ($i = 0; $i < ceil($count['C'] / $batch); $i++) {
                    $selectstmt = $oraconn->query("SELECT * FROM (select t.*, rownum r from " . $row['TABLE_NAME'] . " t) WHERE r > " . ($i*$batch) . " AND r <= " . (($i+1)*$batch));
                    
                    while ($select = $selectstmt->fetch(PDO::FETCH_ASSOC)){
                        array_pop($select);
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
                        $insertstmt = $msconn->prepare("INSERT INTO ".$row['TABLE_NAME']." (".implode(',', array_keys($select)).") VALUES (".implode(', ', array_fill(0,$numColumns,'?')).")");
                        $insertstmt->execute(array_values($select));
                    }
                }
            echo "INSERTED ".$count['C']." ROWS INTO ".$row['TABLE_NAME']."<hr>";
            }
        }
    }else{
        //echo "No Records added to Table {$row['TABLE_NAME']}<br>";
    }
    
}

?>