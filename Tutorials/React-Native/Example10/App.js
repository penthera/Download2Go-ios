import React, { Component } from 'react';
import { StyleSheet, Text, View, Button, NativeEventEmitter  } from 'react-native';
import { NativeModules } from 'react-native';
import ProgressBar from 'react-native-progress/Bar'

// Expose the Virtuoso Download Engine via the Example10_Controller bridge
//
// The following methods are available:
//
//  startEngine -- initializes the download processing and sets up delegate methods for status updates
//  fastPlay -- download and play an asset as soon as possible using FastPlay
//  deleteDownload -- delete the downloaded asset

const example10_Controller = NativeModules.Example10_Controller;

// Allow the Virtuoso Download Engine to send event notifications to the view for processing

const example10_ControllerEmitter = new NativeEventEmitter(NativeModules.Example10_Controller);

export default class App extends Component {
    constructor() {
        super();    
       
        // View state is updated with this listener.  If you update the view
        // make sure the native ViewBridge [refreshView] method mirrors the Javascript state.

        // All listeners should be removed in componentWillUnmount.

        this.refreshViewListener = example10_ControllerEmitter.addListener(
            'refreshView',
            (refresh) => {
              this.setState(refresh);
            }
          );

        this.state = {
            statusText : "",
            fastPlayButtonDisabled : true,
            deleteButtonDisabled : true,
            downloadProgressBarVisible : false,
            downloadProgress : 0.0, 
        }
    }

    render() {
        return (          
            <View style={styles.container}>
              <View style={styles.fillHorizontally}>
                  <Button title="FastPlay" color="#f194ff" disabled = {this.state.fastPlayButtonDisabled} onPress={() => example10_Controller.fastPlay()} />
                  <Button title="Delete" color="#f194ff" disabled = {this.state.deleteButtonDisabled} onPress={() => example10_Controller.deleteDownload()} />
              </View> 
              <View style={styles.fillVertically}>
                  {this.state.downloadProgressBarVisible ? <ProgressBar progress= {this.state.downloadProgress} animated = {this.state.downloadProgressBarVisible} width={200}/> : null}    
                  <Text style={styles.titleText}> {this.state.statusText} </Text>
              </View>             
            </View>
        );   
    }

    componentDidMount() {
        // Start the Virtuoso Download Engine

        example10_Controller.startEngine();
    }   

    componentWillUnmount() {
        // Remove our listeners...

        this.refreshViewListener.remove();
    }
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
    },
    fillHorizontally: {
        flex: 1,
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center'
    },
    fillVertically: {
        flex: 1,
        flexDirection: 'column',
        justifyContent: 'space-evenly',
        alignItems: 'center'
    }
});