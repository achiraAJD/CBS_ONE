<?php
$db_username = "sabn";
$db_password = "sabnxpt_bn";
$db = "odbc:SABNXPT";
$conn = new PDO($db,$db_username,$db_password);

$stmt = $conn->query("
    SELECT  TABLE_NAME,COLUMN_ID,COLUMN_NAME,DATA_TYPE,DATA_LENGTH,DATA_PRECISION,NULLABLE,DEFAULT_LENGTH 
    FROM ALL_TAB_COLUMNS
    WHERE OWNER = 'SABN' 
    ORDER BY TABLE_NAME ASC, COLUMN_ID ASC;
");

$tableName = null;
$sql = ''; $grant = '';

while ($row = $stmt->fetch(PDO::FETCH_ASSOC)){
    #echo  '<pre>';print_r($row);echo '</pre>';
    if (strpos($row['TABLE_NAME'], '=')) {continue;}
    if($row['TABLE_NAME'] != $tableName){
        //$sql = rtrim($sql, ', '); 
        $sql .= ')<br><br>';
        $tableName = $row['TABLE_NAME'];
        $sql .= "CREATE TABLE $tableName (<br>";
        $grant .= "GRANT INSERT ON $tableName TO  WebUser;<br>";
    }
        
    if($row['DATA_TYPE'] == 'NUMBER'){
        $row['DATA_TYPE'] = 'NUMERIC';
    }
        
    if($row['DATA_TYPE'] == 'VARCHAR2'){
        $row['DATA_TYPE'] = 'VARCHAR';
    }
        
    if($row['DATA_TYPE'] == 'DATE'){
        $row['DATA_TYPE'] = 'DATETIME';
    }

    if($row['DATA_TYPE'] == 'LONG RAW'){
        $row['DATA_TYPE'] = 'IMAGE';
    }

    if($row['DATA_TYPE'] == 'RAW'){
        $row['DATA_TYPE'] = 'VARBINARY';
    }

    if($row['DATA_TYPE'] == 'LONG' || $row['DATA_TYPE'] == 'CLOB'){
        $row['DATA_TYPE'] = 'VARCHAR(MAX)';
    }

    $sql .= "[".$row['COLUMN_NAME']."] ".$row['DATA_TYPE'] . " ";

    if ($row['DATA_TYPE'] != 'DATETIME' && (!empty($row['DATA_PRECISION']) || !empty($row['DATA_LENGTH']))) {
        $sql .= "(".($row['DATA_TYPE'] != 'NUMERIC' ? $row['DATA_LENGTH'] : (empty($row['DATA_PRECISION']) ? $row['DATA_LENGTH'] : $row['DATA_PRECISION'])).") ";
    }
        
    if($row['NULLABLE'] == 'Y'){
        $sql .= "   NULL";
    }else{
        $sql .= "   NOT NULL ";
    }

    $sql .= ',<br>';
    
}

$sql = ltrim($sql, ')');
$sql .= ")";

echo $sql;

echo $grant;

?>