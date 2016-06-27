<center> 
    <h1>AlchemyRandom</h1> 
</center>

<p align="center">
    <img src="https://img.shields.io/badge/platform-osx-lightgrey.svg" alt="Platform">
    <img src="https://img.shields.io/badge/language-swift-orange.svg" alt="Language">
    <img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License">
</p>

<p align="center">
    <a href="#requirements">Requirements</a>
    <a href="#installation">Installation</a>
    <a href="#usage">Usage</a>
    <a href="#references">References</a>
    <a href="#license">License</a>
    <a href="#todo">TODO</a>
</p>

AlchemyRandom is a Swift package for random number generators and distributions

## Requirements

- Xcode
    - Version: **8.0 beta (8S128d)**
    - Language: **Swift 3.0**
- OS X
    - Latest SDK: **macOS 10.12**
    - Deployment Target: **OS X 10.10**

While AlchemyRandom has only been tested on OS X with a beta version of Xcode, 
it should presumably work on iOS, tvOS, and watchOS as well.  It only depends on the 
the Swift standard library with optional added extensions to CoreGraphics and simd. 

## Installation

Install using the [Swift Package Manager](https://swift.org/package-manager/)

Add the project as a dependency to your Package.swift:

```swift
import PackageDescription

let package = Package(
    name: "MyProjectUsingAlchemyRandom",
    dependencies: [
        .Package(url: "https://github.com/chris-al-brown/alchemy-random", majorVersion: 0, minor: 1)
    ]
)
```

Then import `import AlchemyRandom`.

## Usage

Check out 'Demo.playground' for example usage.

## References

1. [Random Number Generators in Swift](http://www.cocoawithlove.com/blog/2016/05/19/random-numbers.html)

## License

AlchemyRandom is released under the [MIT License](LICENSE.md).

## TODO
