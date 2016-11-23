<?php

// usage
// http://roocell.homeip.net:11111/user.php?cmd=add&uuid=thisismyuuid&apns_token=thisismyapnstoken&lat=0&lon=0

// http://roocell.homeip.net:11111/user.php?cmd=update&uuid=thisismyuuid&&lat=1&lon=1

// http://roocell.homeip.net:11111/user.php?cmd=getusers&uuid=myuuid

// http://roocell.homeip.net:11111/user.php?cmd=contact&uuid=myuuid&dest_uuid=theiruuid&message=mymessagetext

include "apns/push.php"; // will also include db.php

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
$apns_token=0; $lat=0; $lon=0; $debug=0;
if(isset($_REQUEST['apns_token'])) $apns_token=$_REQUEST['apns_token'];
if(isset($_REQUEST['lat'])) $lat=$_REQUEST['lat'];
if(isset($_REQUEST['lon'])) $lon=$_REQUEST['lon'];
if(isset($_REQUEST['debug'])) $debug=$_REQUEST['debug'];

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
        $sql = "INSERT INTO users (uuid, apns_token, lat, lon, debug) VALUES ('$uuid', '$apns_token', '$lat', '$lon', '$debug')";
        $rc = $db->query($sql);
        if ($rc) echo json_encode(array("status"=>"success", "reason"=>"inserted","uuid"=>"$uuid"));
        else echo json_encode(array("status"=>"failed", "error"=>"failed to insert", "mysql_rc"=>$db->errorInfo()));
    } else {
        // we might be updating the apns-token and debug flag (if testflight install is downloaded over an xcode install)
        // it exists - just overwrite the fields
        $sql = "UPDATE users SET apns_token='$apns_token',debug='$debug' WHERE uuid='$uuid'";
        $rc = $db->query($sql);
        if ($rc) echo json_encode(array("status"=>"success", "reason"=>"exists","uuid"=>"$uuid"));
        else echo json_encode(array("status"=>"failed", "error"=>"failed to update", "mysql_rc"=>$db->errorInfo()));
    }
    break;
  case "update":
    $sql = "UPDATE users SET lat='$lat',lon='$lon' WHERE uuid='$uuid'";
    $res = $db->query($sql);
    if ($res) echo json_encode(array("status"=>"success", "reason"=>"updated","uuid"=>"$uuid"));
    else echo json_encode(array("status"=>"failed", "error"=>"failed to update", "mysql_rc"=>$db->errorInfo()));
    break;
  case "getuuids":
    $sql = "SELECT uuid FROM users WHERE 1";
    $res = $db->query($sql);
    if ($res) echo json_encode(array("status"=>"success", "data"=>$res->fetchAll(PDO::FETCH_COLUMN,0)));
    else echo json_encode(array("status"=>"failed", "error"=>"sql error", "mysql_rc"=>$db->errorInfo()));
    break;
  case "getusers":
    // TODO: probably shouldn't be sending the apns_token in this
    $sql = "SELECT * FROM users WHERE 1";
    $res = $db->query($sql);
    if ($res) echo json_encode(array("status"=>"success", "data"=>$res->fetchAll()));
    else echo json_encode(array("status"=>"failed", "error"=>"sql error", "mysql_rc"=>$db->errorInfo()));
    break;
  case "contact":
    // dest_uuid required
    if(!isset($_REQUEST['dest_uuid']) || $_REQUEST['dest_uuid']=="")
    {
            $msg = array ('status' => 'invalid_input');
            echo json_encode($msg);
            exit();
    }
    $dest_uuid=$_REQUEST['dest_uuid'];
    $message="hello you";
    if(isset($_REQUEST['message'])) $message=$_REQUEST['message'];

    // send a push notification
    $result=sendpush($dest_uuid,$message);
  	echo json_encode($result);

    break;

}
$db=NULL; // required to free resources

?>
