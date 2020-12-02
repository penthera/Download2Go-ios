Tutorial - Example14: Background Wake Processing
=======================================
<br/>

## Summary
This sample demonstrates how to configure Penthera background wake processing using VirtuosoRefreshManager.

</br>
</br>

## Project Setup

1) Change info.plist to add setting "Permitted background task scheduler identifiers" which is an array of identifiers. Then add identifier "com.virtuoso.wake.refresh"

2) In Capabilities, enable Background Fetch and Background Processing modes.

3) In AppDelegate Register your VirtuosoRefreshManagerDelegate in AppDelegate didFinishLaunchingWithOptions method.


To demonsrate how the wake feature works, download and play the asset. Once played, delete the asset and background the App for 12 minutes. While the app is backgrounded, connected to power and WiFi connected, after a 10 minute delay your delegate will be invoked and if the new Playlist episode does not exist, it will be added and downloading will commence.


