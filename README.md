##Apartment - Home Automation for iOS/WatchOS using Home Assistant

Apartment is a native iOS app for [Home Assistant](https://home-assistant.io/), written entirely in Swift.

Apartment also includes an Apple Watch App with a glance and complication, so you can see the status of a given group just by looking at your wrist.

Planned is a tvOS app, so you can have a nice, large-screen dashboard of how your home is doing, viewed from... your home.

####Screenshots

See the [Screenshots](screenshots) folder.

####Building

```
git clone https://github.com/younata/Apartment.git
cd Apartment
brew update
brew install carthage # or brew update carthage
carthage bootstrap --no-use-binaries
open Apartment.xcodeproj
```

You may/will probably need a development certificate to build the carthage libraries on your own. Thankfully, those are free now.
