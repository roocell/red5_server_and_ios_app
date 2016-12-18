var getServer = function() {
  var url = 'http://roocell.homeip.net:11111/server.php?uuid=abc123';
  console.log(url);
  return fetch(url)
  .then((response) => response.json())
  .then((responseJson) => {
    var len = responseJson.data.length;
    //console.log(responseJson.data);
    for (var i=0; i<len; ++i)
    {
      if (this.props.list=="userlist")
      {
        console.log(responseJson.data[i].uuid);
        this.state.user_list.push(responseJson.data[i].uuid);
      } else if (this.props.list=="streamlist") {
        console.log(responseJson.data[i]);
        this.state.user_list.push(responseJson.data[i]);
      }
    }
    if (len==0)
    {
      this.state.user_list.push("<empty>");
    }
    this.updateUserListTable();
  })
  .catch((error) => {
    console.log(error);  // NOTE: console.error - kills the app (it's an assert)
  });
}

exports.getServer = getServer;
