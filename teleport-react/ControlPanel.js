import React, { Component } from 'react';
import {
  View,
  Text,
  ListView
} from 'react-native';

import styles from './styles';

// react has a component called ListView which is used for tables
// but some other 3rd party components can do more
// https://www.npmjs.com/package/react-native-tableview

export default class ControlPanel extends Component {
  constructor() {
    super();
    const ds = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});
    this.state = {
      dataSource: ds.cloneWithRows(['Users', 'Streams']),
    };
  }


  render() {
    return (
      <View style={styles.controlPanel}>
      <ListView
        dataSource={this.state.dataSource}
        renderRow={(rowData) => <Text>{rowData}</Text>}
      />

{/*}
      <View style={styles.controlPanel}>
        <Text style={styles.controlPanelWelcome}>
          Control Panel
        </Text>
        <Button
          onPress={() => {
            this.props.closeDrawer();
          }}
          text="Close Drawer"
        />
        */}
      </View>
    )
  }
}
