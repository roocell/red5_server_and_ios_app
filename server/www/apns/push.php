<?php
if (__FILE__ == $_SERVER['SCRIPT_FILENAME'])
{
		//file was navigated to directly
		$using_function_call=0;
} else {
    $using_function_call=1;
}
$path = $_SERVER['DOCUMENT_ROOT'];
$path .= "/db.php";
include_once($path);

// at some point the permissions on this file should be changed back to 700 so that only root (docker containers) can call this script.
// otherwise anyone outside the network can trigger push notification with the right information


// usage
// to call via browser
// http://roocell.homeip.net:11111/apns/push.php?uuid=114EE774-26A2-4CB6-971D-B8487F3C04ED&message=this is my message

// to insert row in db
// insert into users (uuid,apns_token, lat, lon) values ("1C778026-12D2-447B-A948-13584B9C5AE0","43bc99d817ad6cf308a0e457adedfbfab9bae81f5638fca6264205845f304ddf", 0, 0)
// insert into users (uuid,apns_token, lat, lon) values ("37D42C69-DD2A-4503-B02F-39F56F32D45B","415f2bec9b9dcae09283411ca12b9914aad5bf59c9b3fe25051c53de5e828e71", 0, 0)


function sendpush ($dest_uuid, $message)
{
	global $dsn, $usr, $pwd;

	try {
	    $db = new PDO($dsn, $usr, $pwd);
	} catch (PDOException $e) {
	    die('Connection failed: ' . $e->getMessage());
	}
	$apns_token=0;
	$sql="SELECT * FROM users WHERE uuid='$dest_uuid'";
	foreach ($db->query($sql) as $row) {
	  $apns_token = $row['apns_token'];
	}
	if ($apns_token)
	{
	  $token_status="found";
		$use_apns_sandbox=$row['debug'];
	} else {
		$rc=array('status' => 'failed', 'token_status' => 'not found');
		return $rc;
	}
	$db=NULL;


	// data is the data we want to pass inside the push notif
	// here we can send information of the user who's trying to contact the pushed user
	$data = array ('uuid' => $dest_uuid);


	////////////////////////////////////////////////////////////////////////////////
	// Open a connection to the APNS server
	if ($use_apns_sandbox)
	{
		$passphrase = 'admin123'; // Put your private key's passphrase here:
		$ctx = stream_context_create();
		stream_context_set_option($ctx, 'ssl', 'local_cert', $_SERVER['DOCUMENT_ROOT']."/apns/teleport.pem");
		stream_context_set_option($ctx, 'ssl', 'passphrase', $passphrase);
	        $fp = stream_socket_client(
	        'ssl://gateway.sandbox.push.apple.com:2195', $err,
	        $errstr, 60, STREAM_CLIENT_CONNECT|STREAM_CLIENT_PERSISTENT, $ctx);
	} else {
		$passphrase = 'admin123'; // Put your private key's passphrase here (used when exporting the p12 file)
		$ctx = stream_context_create();
		stream_context_set_option($ctx, 'ssl', 'local_cert', $_SERVER['DOCUMENT_ROOT']."/apns/teleport_production.pem");
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
	$rc=array('status' => $status, 'token_status' => $token_status, 'token' => $apns_token);
	return $rc;
}
if ($using_function_call==0)
{
	header("Content-Type: text/json");
	error_reporting(E_ALL); ini_set('display_errors', '1');

	if(!isset($_REQUEST['uuid']) || $_REQUEST['uuid']=="")
	{
		$msg = array ('status' => 'invalid_input');
		echo json_encode($msg);
		exit();
	}
	$uuid=$_REQUEST['uuid'];

	// Put your alert message here:
	if(!isset($_REQUEST['message']) || $_REQUEST['message']=="")
	{
		$message = "<empty message>";
	} else {
		$message = $_REQUEST['message'];
	}

	$result=sendpush($uuid,$message);
	echo json_encode($result);
	exit();
}
