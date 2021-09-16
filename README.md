# SpaceXDemo
iOS demo to display SpaceX data with Swift

This is a demo app to demonstrate MVVM design pattern with RxSwift.

Base Api URL from SpaceX
https://api.spacexdata.com/v3

Dependencies
The following dependencies are managed by Cocoapods.
To run the code, go to the project folder in the terminal and run pod install, then open the SpaceXDemo.xcworkspace.

Rxswift
RxCocoa
RxDataSources

Launching the app will fetch data from SpaceX api, and then show the launches with flight number, launch year and mission name.
Clicking the cell will show the details of the specific launch.
Tapping the accessory button of the cell will navigate user to Wikipedia page about the rocket.
Implemented sorting fearture, including sorting launches by either launch date or mission name.
Can filter by successful launches.
I also add a reset feature to reset the data.
