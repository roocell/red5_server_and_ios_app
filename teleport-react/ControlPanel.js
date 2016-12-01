import React, { Component } from 'react';
import {
  View,
  Text,
  ListView,
  TouchableHighlight,
  StyleSheet,
  RecyclerViewBackedScrollView,
  Navigator,
} from 'react-native';

var styles = StyleSheet.create({
  container: {
    top:25,
    backgroundColor: '#F6F6F6',
    flex: 1,
  },
  list: {
  },
  row: {
    flexDirection: 'row',
    justifyContent: 'center',
    padding: 10,
    backgroundColor: '#F6F6F6',
  },
  thumb: {
    width: 64,
    height: 64,
  },
  text: {
    flex: 1,
  },
});


// react has a component called ListView which is used for tables
// but some other 3rd party components can do more
// https://www.npmjs.com/package/react-native-tableview

const routes = [
  {title: 'First Level Menu', index: 0},
  {title: 'Second Level Menu', index: 1},
];


var ControlPanel = React.createClass({
  statics: {
    title: '<ListView>',
    description: 'Performant, scrollable list of data.'
  },

  getInitialState: function() {
    var ds = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});
    return {
      dataSource: ds.cloneWithRows(['Users', 'Streams']),
    };
  },

  _pressData: ({}: {[key: number]: boolean}),

  componentWillMount: function() {
    this._pressData = {};
  },

  render() {

    return (
      <View style={styles.container}>
        <Navigator
          initialRoute={routes[0]}
          initialRouteStack={routes}
          renderScene={(route, navigator) =>
            <ListView
              style={styles.list}
              dataSource={this.state.dataSource}
              renderRow={this._renderRow}
              renderScrollComponent={props => <RecyclerViewBackedScrollView {...props} />}
              renderSeparator={this._renderSeparator}
            />
          }
        />
      </View>
    )
  },


  _renderRow: function(rowData: string, sectionID: number, rowID: number, highlightRow: (sectionID: number, rowID: number) => void) {
    return (
      <TouchableHighlight onPress={() => {
          this._pressRow(rowID);
          highlightRow(sectionID, rowID);
        }}>
        <View>
          <View style={styles.row}>
            {/*
            <Image style={styles.thumb} source={imgSource} /> */}
            <Text style={styles.text}>
              {rowData}
            </Text>
          </View>
        </View>
      </TouchableHighlight>
    );
  },

  _pressRow: function(rowID: number) {
    this._pressData[rowID] = !this._pressData[rowID];

    // load in the next ListView
    console.log("touched " + rowID);
    if (rowID === 0) {
      navigator.push(routes[1]);
    } else {
      navigator.pop();
    }

    //this.setState({dataSource: this.state.dataSource.cloneWithRows(
    //  this._genRows(this._pressData)
    //)});
  },

  _renderSeparator: function(sectionID: number, rowID: number, adjacentRowHighlighted: bool) {
    return (
      <View
        key={`${sectionID}-${rowID}`}
        style={{
          height: adjacentRowHighlighted ? 4 : 1,
          backgroundColor: adjacentRowHighlighted ? '#3B5998' : '#CCCCCC',
        }}
      />
    );
  }
});
module.exports = ControlPanel;
