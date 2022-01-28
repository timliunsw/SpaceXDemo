# SpaceXDemo
An iOS demo to display SpaceX data with Swift and demonstrate **MVVM** design pattern with **RxSwift**

**API documents are available here**: https://docs.spacexdata.com

**Base URL from SpaceX**: https://api.spacexdata.com/v3

## Dependencies

The following dependencies are managed by Cocoapods.
```
Rxswift
RxCocoa
RxDataSources
```
CocoaPods is a dependency manager for Cocoa projects. Install it with the following command:

```$ gem install cocoapods```

To run the code, go to the project folder in the terminal and run the following command:

```$ pod install```

Then open the ```SpaceXDemo.xcworkspace``` file.

## Feature
* Display a list of launches, which are from SpaceX api. ```(flight number, mission name, year)```
* Ability to sort launches by either launch date or mission name
  * When sorted by launch date, launches are grouped by year
  * When sorted by mission name, launches are grouped by the first alphabet
* Ability to filter launches by success/failure
  * Cross icon indicates failure of the launch
  * Check mark icon indicates success of the launch
* When a launch is selected display a screen with detailed launch information and the
rocket details used for the launch
  * Launch information is from One Launch endpoint
  * Rocket details is from One Rocket endpoint
* Tap detail button of each cell will navigate users to Wikipedia page about the launch
* Reset Button is to reset the data set
* Support dark mode
* Implemented autolayout
* Unit tests are provided
* UI tests are provided