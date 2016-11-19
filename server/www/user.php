<?php

// usage
// http://roocell.homeip.net:11111/user.php?cmd=add&uuid=thisismyuuid&apns_token=thisismyapnstoken&lat=0&lon=0

// http://roocell.homeip.net:11111/user.php?cmd=update&uuid=thisismyuuid&&lat=1&lon=1

include "db.php";
header("Content-Type: text/json");
error_reporting(E_ALL); ini_set('display_errors', '1');

if(!isset($_REQUEST['uuid']) || $_REQUEST['uuid']=="")
{
        $msg = array ('status' => 'invalid_input');
        echo json_encode($msg);
        exit();
}
if(!isset($_REQUEST['cmd']) || $_REQUEST['cmd']=="")
{
        $msg = array ('status' => 'invalid_input');
        echo json_encode($msg);
        exit();
}

// apns_token, location  may be optional (user may not allow push notifications)
$apns_token=0; $lat=0; $lon=0;
if(isset($_REQUEST['apns_token'])) $apns_token=$_REQUEST['apns_token'];
if(isset($_REQUEST['lat'])) $lat=$_REQUEST['lat'];
if(isset($_REQUEST['lon'])) $lon=$_REQUEST['lon'];

$uuid=$_REQUEST['uuid'];
$cmd=$_REQUEST['cmd'];

try {
    $db = new PDO($dsn, $usr, $pwd);
} catch (PDOException $e) {
    echo json_encode(array("status"=>"failed", "error"=>$e->getMessage()));
    exit();
}
$sql="SELECT COUNT(*) FROM users WHERE uuid='$uuid'";
$res=$db->query($sql);
$num_rows = $res->fetchColumn();

switch ($cmd)
{
  case "add":
    if ($num_rows==0)
    {
        // insert new user
        $sql = "INSERT INTO users (uuid, apns_token, lat, lon) VALUES ('$uuid', '$apns_token', '$lat', '$lon')";
        $rc = $db->query($sql);
        if ($rc) echo json_encode(array("status"=>"success", "reason"=>"inserted","uuid"=>"$uuid"));
        else echo json_encode(array("status"=>"failed", "error"=>"failed to insert", "mysql_rc"=>$db->errorInfo()));
    } else {
      echo json_encode(array("status"=>"success", "reason"=>"exists","uuid"=>"$uuid"));
    }
    break;
  case "update":
    $sql = "UPDATE users SET lat='$lat',lon='$lon' WHERE uuid='$uuid'";
    $rc = $db->query($sql);
    if ($rc) echo json_encode(array("status"=>"success", "reason"=>"updated","uuid"=>"$uuid"));
    else echo json_encode(array("status"=>"failed", "error"=>"failed to update", "mysql_rc"=>$db->errorInfo()));
    break;

}
$db=NULL;

?>
