import React, { Component } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Platform,
} from 'react-native';

// https://github.com/airbnb/react-native-maps/blob/master/docs/installation.md
// if you do a clean - you'll have to rebuild like this
// react-native link
// react-native run-ios


import styles from './styles';
import Button from './Button';

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
    flex: 1,
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

export default class MainView extends Component {
  setParentState(args){
    this.props.setParentState(args)
  }

 render(){
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

          <View style={buttonstyles.container}>
             {/* put icons after the maps in order for them to appear above
              absolute position */}
             <Icon name="bars" size={30} onPress={this.props.openDrawer} style={buttonstyles.menu}>
             </Icon>
             <Icon name="video-camera" color={'red'} size={30} onPress={this.props.openDrawer} style={buttonstyles.video}>
             </Icon>
         </View>




  </View>


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
