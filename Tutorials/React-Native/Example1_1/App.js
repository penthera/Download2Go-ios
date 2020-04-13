import React, { Component } from 'react';
import { StyleSheet, Text, View, Button, NativeEventEmitter, Switch } from 'react-native';
import { NativeModules } from 'react-native';
import ProgressBar from 'react-native-progress/Bar'

// Expose the Virtuoso Download Engine via the Example1_1Controller bridge
//
// The following methods are available:
//
//  startEngine -- initializes the download processing and sets up delegate methods for status updates
//  download -- downloads a sample asset
//  playDownload -- plays the downloaded asset
//  deleteDownload -- delete the downloaded asset
//  pauseDownload -- pause or resume download. Requires a boolean parameter indicating download should pause(true) or resume(false) 

const example1_1Controller = NativeModules.Example1_1Controller;

// Allow the Virtuoso Download Engine to send event notifications to the view for processing

const example1_1ControllerEmitter = new NativeEventEmitter(NativeModules.Example1_1Controller);

export default class App extends Component {
    constructor() {
        super();    
       
        // View state is updated with this listener.  If you update the view
        // make sure the native ViewBridge [refreshView] method mirrors the Javascript state.

        // All listeners should be removed in componentWillUnmount.

        this.refreshViewListener = example1_1ControllerEmitter.addListener(
            'refreshView',
            (refresh) => {
              if (!refresh.downloadProgressBarVisible) {
                refresh.downloadPaused = false;
              }
              this.setState(refresh);
            }
          );

        this.state = {
            statusText : "",
            downloadButtonDisabled : true,
            playButtonDisabled : true,
            deleteButtonDisabled : true,
            downloadProgressBarVisible : false,
            downloadProgress : 0.0,

            // It is NOT necessary to maintain this state in the bridge (native code)
            // The state will be passed to the bridge method.

            downloadPaused : false  
        }
    }

    render() {
        return (          
            <View style={styles.container}>
              <View style={styles.fillHorizontally}>
                <Text style={this.state.downloadProgressBarVisible ? styles.titleText : [styles.titleText, {color: 'rgba(0,0,0,0.26)'}] }> {"Pause Downloading"} </Text>
                <Switch disabled = {!this.state.downloadProgressBarVisible} 
                  value = {this.state.downloadPaused} 

                  // onChange will be invoked before the state is updated, pass the flipped value

                  onChange={(event) => example1_1Controller.pauseDownload(!this.state.downloadPaused)}
                  onValueChange = {(value) => {this.setState({ downloadPaused: value })}}
                />
              </View>
              <View style={styles.fillHorizontally}>
                  <Button title="Download" color="#f194ff" disabled = {this.state.downloadButtonDisabled} onPress={() => example1_1Controller.download()}/>
                  <Button title="Play" color="#f194ff" disabled = {this.state.playButtonDisabled} onPress={() => example1_1Controller.playDownload()} />
                  <Button title="Delete" color="#f194ff" disabled = {this.state.deleteButtonDisabled} onPress={() => example1_1Controller.deleteDownload()} />
              </View> 
              <View style={styles.fillVertically}>
                  {this.state.downloadProgressBarVisible ? <Text style={styles.titleText}> {this.state.downloadPaused ? "Downloading Paused" : "Downloading... "} </Text> : null}  
                  {this.state.downloadProgressBarVisible ? <ProgressBar progress= {this.state.downloadProgress} animated = {this.state.downloadProgressBarVisible} width={200}/> : null}    
                  <Text style={styles.titleText}> {this.state.statusText} </Text>
              </View>             
            </View>
        );   
    }

    componentDidMount() {
        // Start the Virtuoso Download Engine

        example1_1Controller.startEngine();
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