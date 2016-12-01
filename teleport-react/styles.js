import { StyleSheet, PixelRatio } from 'react-native';
const deviceScreen = require('Dimensions').get('window')

module.exports = StyleSheet.create({
  scrollView: {
    backgroundColor: '#B99BC4',
  },
  container: {
    flex: 1,
    backgroundColor: 'white',
  },
  controlPanel: {
    flex: 1,
    backgroundColor:'#326945',
  },

});
