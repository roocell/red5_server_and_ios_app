<?php
ini_set('display_errors', 1);
ini_set('exit_on_timeout', 1);
error_reporting(E_ALL | E_STRICT);
// https://www.red5pro.com/docs/server/serverapi/#streams-api
$RED5IP= getenv('RED5IP');

//echo $RED5IP."<BR>";

// seems best to use curl over file_get_contents
// http://stackoverflow.com/questions/16700960/how-to-use-curl-to-get-json-data-and-decode-the-data
// http://stackoverflow.com/questions/11064980/php-curl-vs-file-get-contents

$url = "http://$RED5IP:5080/api/v1/server?accessToken=zaq12wsx";
$url = "http://$RED5IP:5080/api/v1/applications?accessToken=zaq12wsx";
$url = "http://$RED5IP:5080/api/v1/applications/live/streams?accessToken=zaq12wsx";


//  Initiate curl
$ch = curl_init();
// Disable SSL verification
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
// Will return the response, if false it print the response
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
// Set the url
curl_setopt($ch, CURLOPT_URL,$url);
// Execute
$result=curl_exec($ch);
// Closing
curl_close($ch);

// Will dump a beauty json :3
//var_dump(json_decode($result, true));

echo $result;

?>
