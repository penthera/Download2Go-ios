import React, { Component } from 'react';
import { StyleSheet, Text, View, Button, NativeEventEmitter } from 'react-native';
import { NativeModules } from 'react-native';
import ProgressBar from 'react-native-progress/Bar'

// Expose the Virtuoso Download Engine via the HelloWorldController bridge
//
// The following methods are available:
//
//  startEngine -- initializes the download processing and sets up delegate methods for status updates
//  download -- downloads a sample asset
//  playDownload -- plays the downloaded asset
//  deleteDownload -- delete the downloaded asset

const helloWorldController = NativeModules.HelloWorldController;

// Allow the Virtuoso Download Engine to send event notifications to the view for processing

const helloWorldControllerEmitter = new NativeEventEmitter(NativeModules.HelloWorldController);

export default class App extends Component {
    constructor() {
        super();    
       
        // View state is updated with this listener.  If you update the view
        // make sure the HelloWorld [refreshView] method mirrors the Javascript state.

        // All listeners should be removed in componentWillUnmount.

        this.refreshViewListener = helloWorldControllerEmitter.addListener(
            'refreshView',
            (refresh) => { 
                this.setState(refresh);
            }
          );

        this.state = {
            statusText : "",
            downloadButtonDisabled : true,
            playButtonDisabled : true,
            deleteButtonDisabled : true,
            downloadProgressBarVisible : false,
            downloadProgress : 0.0
        }
    }

    render() {
        return (
            <View style={styles.container}>
                <View style={styles.fillButtonsHorizontally}>
                    <Button title="Download" color="#f194ff" disabled = {this.state.downloadButtonDisabled} onPress={() => helloWorldController.download()}/>
                    <Button title="Play" color="#f194ff" disabled = {this.state.playButtonDisabled} onPress={() => helloWorldController.playDownload()} />
                    <Button title="Delete" color="#f194ff" disabled = {this.state.deleteButtonDisabled} onPress={() => helloWorldController.deleteDownload()} />
                </View> 
                <View style={styles.fillStatusVertically}>
                    {this.state.downloadProgressBarVisible ? <Text style={styles.titleText}> {"Downloading..."} </Text> : null}  
                    {this.state.downloadProgressBarVisible ? <ProgressBar progress= {this.state.downloadProgress} animated = {this.state.downloadProgressBarVisible} width={200}/> : null}    
                    <Text style={styles.titleText}> {this.state.statusText} </Text>
                </View>             
            </View>
        );   
    }

    componentDidMount() {
        // Start the Virtuoso Download Engine

        helloWorldController.startEngine();
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
    fillButtonsHorizontally: {
        flex: 1,
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center'
    },
    fillStatusVertically: {
        flex: 1,
        flexDirection: 'column',
        justifyContent: 'space-evenly',
        alignItems: 'center'
    }
});