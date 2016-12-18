var getStreamServer = function() {
  var url = 'http://roocell.homeip.net:11111/server.php?uuid=abc123';
  console.log(url);
  return fetch(url)
  .then(response => response.json()
    .then(json => {
      if (!response.ok) {
        console.log("BAD RESPONSE" + response)
      }
      //console.log(json.stream_server_ip);
      return Object.assign({ip: json.stream_server_ip, port: json.stream_server_port});
    })
  )
  .catch((error) => {
    console.log(error);  // NOTE: console.error - kills the app (it's an assert)
  });
}
exports.getStreamServer = getStreamServer;
