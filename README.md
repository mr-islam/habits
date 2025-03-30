# Wird Habit Tracker iOS

A port(-ish) of Loop Habit Tracker iOS, a mobile app for creating and maintaining long-term positive habits. It's the iOS version of [Loop Habit Tracker](https://github.com/iSoron/uhabits) for Android.

<p align="center">
  <img src="./Screenshots/screenshot1.png?raw=true" width="350"/>
  <img src="./Screenshots/screenshot2.png?raw=true" width="350" hspace="20"/>
</p>

## Intro
Looks like this is SwitftUI, since the reference in xcode opens the `SwiftUICore` docs.

## New Plans
### Core
- [ ] Notifications for habits
- [ ] Add tests
- [ ] Support landscape with extra days displayed (or maybe make the number of day a dynamic thing based on screen size)
- [ ] Gentle haptic feedback for check, and another for uncheck
- [ ] Add filters for the habits (archived or not, not done today or not)
- [ ] move completed habits to bottom
- [ ] upload to app store
- [ ] import and export habit data

### Later
- [ ] Localization support i18n
- [ ] Custom number habits not just binary
- [ ] Skip support for habit instance
- [ ] Fix calendar on habit details screen
- [ ] Handle onboarding with epxlanations
- [ ] Handle empty habits screen (ie. no habits) - maybe start with sample habit?
- [ ] Update screenshots
- [ ] Prep for app store
- [ ] Better icon with subha concept
- [ ] Fill in about info on settings page
- [ ] move to sufone org on github 
- [ ] Archived habit support

### Really later
- [ ] compatibility with loop habit data format
- [ ] Support archiving habits
- [ ] Habit groups
- [ ] Compare to Loop and see core features that are necessary
- [ ] See feature requests on the Loop repo
- [ ] Theming system
- [ ] Icon options and choices (premium maybe? cosmetic things only)
- [ ] Handle making black text white in dark mode
- [ ] Show circle on left of habit as it's score/health, like loop

## Completed
- [x] Update README
- [x] Confirm if this is UIKit or SwiftUI
- [x] Fix the dates newline on main screen
- [x] Set it to be 5 days on portait (or dynamic?)
- [x] Make the Main title "Habits" nicer
- [x] Fix dark mode text being black
- [x] add delete habit function (on edit page)
- [x] Support reversing of days (ie. the latest day on the right)
- [x] Icon
- [x] App title and branding
- [x] Options screen and about together

## License

Habits
Copyright (C) 2025  Naved Islam

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

Previously Apache License from Oleksandr T
