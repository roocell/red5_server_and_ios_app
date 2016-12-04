'use strict';
import React, { Component } from 'react';

import {
  AppRegistry,
  StyleSheet,
  Text,
  ListView,
  View,
  ScrollView,
  TouchableHighlight,
  AsyncStorage
} from 'react-native';

var Button = require('react-native-button');
var GiftedSpinner = require('react-native-gifted-spinner');

var api = require('./src/fetchapi.js');

var moment = require('moment');


//https://www.youtube.com/watch?v=xm_rSbqSN5o
var UserList = React.createClass({


    getInitialState: function() {

      const ds = new ListView.DataSource({
          rowHasChanged: (r1, r2) => r1 !== r2,
        });

      return {
        loaded: false,
        user_list: ['back'],
        dataSource: ds.cloneWithRows(['back']),
      };

    },



    render: function() {

        return (
            <ListView
              initialListSize={1}
              dataSource={this.state.dataSource.cloneWithRows(this.state.user_list)}
              style={styles.list}
              renderRow={this._renderRow}
              renderSeparator={this._renderSeparator}
            >
            </ListView>

        );

    },

    componentDidMount: function() {

        AsyncStorage.getItem('users').then((user_list_str) => {

            var users = JSON.parse(user_list_str);

            if(users != null){
/*
                AsyncStorage.getItem('time').then((time_str) => {
                    var time = JSON.parse(time_str);
                    var last_cache = time.last_cache;
                    var current_datetime = moment();

                    var diff_days = current_datetime.diff(last_cache, 'days');

                    if(diff_days > 0){
                        this.getUserList();
                    }else{
                        this.updateUserListUI(user_list);
                    }

                });
                */


            } else{
                this.getUserList();
            }

        }).done();

    },

    _renderRow: function(rowData: string, sectionID: number, rowID: number, highlightRow: (sectionID: number, rowID: number) => void) {
        return (
          <TouchableHighlight onPress={() => {
              //this._pressRow(rowID);
              highlightRow(sectionID, rowID);
            }}>
            <View>
              <View style={styles.row}>
                <Text style={styles.text}>
                  {rowData}
                </Text>
              </View>
            </View>
          </TouchableHighlight>
        );
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
    },

    userPressed: function() {
      console.log("user pressed");

    },

    updateUserListUI: function(users){

        if(users.length == TOTAL_NUM_USERS){

            var ds = this.state.dataSource.cloneWithRows(users);
            this.setState({
              'user_list': ds,
              'loaded': true
            });

        }

    },

    updateUserListDB: function(users){

        if(users.length == TOTAL_NUM_USERS){
            AsyncStorage.setItem('user_list', JSON.stringify(users));
        }

    },

    getUserList: function() {

        var USER_LIST_URL = 'http://roocell.homeip.net:11111/users.php?cmd=getusers&uuid=abc123';
        var users = [];

        //AsyncStorage.setItem('time', JSON.stringify({'last_cache': moment()}));
/*
        api(USER_LIST_URL).then(
          (top_stories) => {

                for(var x = 0; x <= 10; x++){

                    var story_url = "https://hacker-news.firebaseio.com/v0/item/" + top_stories[x] + ".json";

                    api(story_url).then(
                        (story) => {

                            users.push(story);
                            this.updateUserListUI(users);
                            this.updateUserListDB(users);

                        }
                    );

                }
            }
        );
*/

    },

});


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
  text: {
    flex: 1,
  },
});

module.exports = UserList;
