# Ostmodern Code Test

This iPhone app downloads the data for all of the episodes from the 'Home' set on the Skylark test platform and displays them in a table. Selecting a cell in the table displays a full screen detail view for the chosen episode.

## Installation

To run this app, you will need to have CocoaPods installed on your computer. CocoaPods is a dependency manager that fetches the source code for all dependencies and maintains an Xcode workspace to build the project. For instructions on getting this installed and running it with the project, visit https://cocoapods.org/.

## Known Issues

There are several minor issues with the app:

- Data is being downloaded from an insecure source (http://)
- The logic for fetching data from the remote source has several flaws
- Pull-to-refresh does not remain visible while the data is loading
- There may be issues when fetching data that is valid but contains zero objects
