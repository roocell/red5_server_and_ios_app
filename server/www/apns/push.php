<?php
header("Content-Type: text/json");
error_reporting(E_ALL); ini_set('display_errors', '1');

// to insert row in db
// insert into users (uuid,apns_token, lat, lon) values ("1C778026-12D2-447B-A948-13584B9C5AE0","43bc99d817ad6cf308a0e457adedfbfab9bae81f5638fca6264205845f304ddf", 0, 0)

// to call via browser
// http://roocell.homeip.net:11111/apns/push.php?uuid=1C778026-12D2-447B-A948-13584B9C5AE0

$use_apns_sandbox=0;

if(!isset($_REQUEST['uuid']) || $_REQUEST['uuid']=="")
{
	$msg = array ('status' => 'invalid_input');
	echo json_encode($msg);
	exit();
}


$uuid=$_REQUEST['uuid'];

// get token based on $apip
$dsn = "mysql:host=".gethostbyname('mysql').";port=3306;dbname=teleport;charset=utf8";
$usr = 'root';
$pwd = 'admin123';
try {
    $db = new PDO($dsn, $usr, $pwd);
} catch (PDOException $e) {
    die('Connection failed: ' . $e->getMessage());
}
$apns_token=0;
$sql="SELECT * FROM users WHERE uuid='$uuid'";
	foreach ($db->query($sql) as $row) {
			// TODO: support multiple sentinels per ap
			$apns_token = $row['apns_token'];
	}
if ($apns_token)
{
  $token_status="found";
} else {
	// Put your device token here (without spaces):
	$apns_token = 'blahblahblah';
	//$deviceToken = 'd4d27240ffeb2a3d5586adad80089e350dcb6ac4b90f6195963d88d2d4d4e117';
	$token_status="default";
}
$db=NULL;


// data is the data we want to pass inside the push notif
// here we can send information of the user who's trying to contact the pushed user
$data = array ('uuid' => $uuid);


// Put your alert message here:
$message = "hi we would like to push you";
////////////////////////////////////////////////////////////////////////////////
// Open a connection to the APNS server
if ($use_apns_sandbox)
{
	$passphrase = 'admin123'; // Put your private key's passphrase here:
	$ctx = stream_context_create();
	stream_context_set_option($ctx, 'ssl', 'local_cert', 'teleport.pem');
	stream_context_set_option($ctx, 'ssl', 'passphrase', $passphrase);
  $fp = stream_socket_client(
        'ssl://gateway.sandbox.push.apple.com:2195', $err,
        $errstr, 60, STREAM_CLIENT_CONNECT|STREAM_CLIENT_PERSISTENT, $ctx);
} else {
	$passphrase = 'admin123'; // Put your private key's passphrase here (used when exporting the p12 file)
	$ctx = stream_context_create();
	stream_context_set_option($ctx, 'ssl', 'local_cert', 'teleport.pem');
	stream_context_set_option($ctx, 'ssl', 'passphrase', $passphrase);
  $fp = stream_socket_client(
				'ssl://gateway.push.apple.com:2195', $err,
	  		$errstr, 60, STREAM_CLIENT_CONNECT|STREAM_CLIENT_PERSISTENT, $ctx);
}
if (!$fp)
{
	$status = "connect_failed";
}
// Create the payload body
$body['aps'] = array(
	'alert' => $message,
	'sound' => 'default',
        'content-available' => '1'
	);
$body['data'] = $data;
// Encode the payload as JSON
$payload = json_encode($body);
//echo $payload;
// Build the binary notification
$msg = chr(0) . pack('n', 32) . pack('H*', $apns_token) . pack('n', strlen($payload)) . $payload;
// Send it to the server
$result = fwrite($fp, $msg, strlen($msg));
if (!$result)
	$status = "not_delivered";
else
	$status = "success";
// Close the connection to the server
fclose($fp);
$reponse=array('status' => $status, 'token_status' => $token_status, 'token' => $apns_token);
echo json_encode($reponse);
