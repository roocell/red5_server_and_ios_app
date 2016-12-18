import React, { Component } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Platform,
  requireNativeComponent,
  NativeModules,
  Navigator,
} from 'react-native';

// https://github.com/airbnb/react-native-maps/blob/master/docs/installation.md
// if you do a clean - you'll have to rebuild like this
// react-native link
// react-native run-ios


// http://stackoverflow.com/questions/37031192/react-native-reload-and-dev-tools-do-not-work


import styles from './styles';

import MapView from 'react-native-maps';
import Icon from 'react-native-vector-icons/FontAwesome';



const mapstyles = StyleSheet.create({
  container: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    justifyContent: 'flex-end',
    alignItems: 'center',
  },
  map: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
  },
});
const buttonstyles = StyleSheet.create({
  container: {
    top: 25,
    //flex: 1,  // will cause height to fill entire screen
    flexDirection: 'row',
    justifyContent: 'space-between',
    backgroundColor: 'transparent',
    padding: 10,
  },
  menu: {
  },
  video: {
  }
});

const { RTCObjBridgeView } = NativeModules;

var getStreamServer = require('./ServerComms.js').getStreamServer;

export default class MainView extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      stream_server: Object.assign({ip: "", port: 0}),
    };
  }
  componentDidMount() {
    getStreamServer()
      .then(stream_server => {
        console.log(stream_server.ip + ":" + stream_server.port);
        this.state.stream_server = stream_server;
      });

  }


  setParentState(args){
    this.props.setParentState(args)
  }

  openPublish(navigator) {
    console.log("press publish");
    if (this.state.stream_server.port != 0)
    {
      RTCObjBridgeView.showPublish(this.state.stream_server.ip, this.state.stream_server.port);
    }
  }
  _renderScene(route, navigator) {
    if (route.component) {
        return React.createElement(route.component, { ...this.props, ...route.passProps, navigator, route } );
    }
    return (
      <View style={styles.container}
        >


            <View style={mapstyles.container}
              >

              <MapView
                style={ mapstyles.map }
                initialRegion={{
                  latitude: 37.78825,
                  longitude: -122.4324,
                  latitudeDelta: 0.0922,
                  longitudeDelta: 0.0421,
                }}
              />

            </View>

{/* put icons after the maps in order for them to appear above
 absolute position */}

             <View style={buttonstyles.container}>
                <Icon name="bars" size={30} onPress={this.props.openDrawer} style={buttonstyles.menu}>
                </Icon>
                <Icon name="video-camera" color={'red'} size={30}
                  onPress={() => {
                    this.openPublish(navigator);
                  }}
                  style={buttonstyles.video}>
                </Icon>
            </View>


     </View>

    )
  }

 render(){
 return (

   <Navigator
    style = {styles.container}
    initialRoute={{
      title: "Root",
      navigationBarHidden: true,
      }}
      renderScene={ (route, navigator) => this._renderScene(route, navigator) }
      >
      </Navigator>
   );
  }
}





// Shadow props are not supported in React-Native Android apps.
// The below part handles this issue.

// iOS Styles
var iosStyles = StyleSheet.create({
  track: {
    height: 2,
    borderRadius: 1,
  },
  thumb: {
    width: 30,
    height: 30,
    borderRadius: 30 / 2,
    backgroundColor: 'white',
    shadowColor: 'black',
    shadowOffset: {width: 3, height: 5},
    shadowRadius: 5,
    shadowOpacity: 0.75,
  }
});

const iosMinTrTintColor = '#1073ff';
const iosMaxTrTintColor = '#b7b7b7';
const iosThumbTintColor = '#343434';

// Android styles
const androidStyles = StyleSheet.create({
  container: {
    height: 40,
    justifyContent: 'center',
  },
  track: {
    height: 4,
    borderRadius: 4 / 2,
  },
  thumb: {
    position: 'absolute',
    width: 20,
    height: 20,
    borderRadius: 20 / 2,
  },
  touchArea: {
    position: 'absolute',
    backgroundColor: 'transparent',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
  },
  debugThumbTouchArea: {
    position: 'absolute',
    backgroundColor: 'green',
    opacity: 0.5,
  }
});

const androidMinTrTintColor = '#26A69A';
const androidMaxTrTintColor = '#d3d3d3';
const androidThumbTintColor = '#009688';


const sliderStyles = (Platform.OS === 'ios') ? iosStyles : androidStyles;
const minimumTrackTintColor = (Platform.OS === 'ios') ? iosMinTrTintColor : androidMinTrTintColor;
const maximumTrackTintColor = (Platform.OS === 'ios') ? iosMaxTrTintColor : androidMaxTrTintColor;
const thumbTintColor = (Platform.OS === 'ios') ? iosThumbTintColor : androidThumbTintColor;
