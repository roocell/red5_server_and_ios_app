<?php
ini_set('display_errors', 1);
ini_set('exit_on_timeout', 1);
error_reporting(E_ALL | E_STRICT);
header("Content-Type: text/json");

// this script is used by the iphone app at startup to get knowledge of what streaming server to use

// for now just return the public IP of my server at home
$ip = file_get_contents('http://api.ipify.org');

// Will dump a beauty json :3
//var_dump(json_decode($result, true));

// build array for JSON
$output['stream_server_ip']=$ip;
$output['stream_server_port']=8554;

// spit out the JSON
echo json_encode($output);

?>
