<?php
ini_set('display_errors', 1);
ini_set('exit_on_timeout', 1);
error_reporting(E_ALL | E_STRICT);

// this script is used by the iphone app at startup to get knowledge of what streaming server to use

// for now just return the public IP of my server at home
$externalContent = file_get_contents('http://checkip.dyndns.com/');
preg_match('/Current IP Address: \[?([:.0-9a-fA-F]+)\]?/', $externalContent, $m);
$externalIp = $m[1];

// build array for JSON
$output['stream_server_ip']=$externalIp;
$output['stream_server_port']=8554;

// spit out the JSON
echo json_encode($output);

?>
