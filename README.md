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
</p>

AlchemyRandom is a Swift package for random number generators and distributions

## Requirements

- Xcode
    - Version: **8.0 beta 2 (8S162m)**
    - Language: **Swift 3.0**
- OS X
    - Latest SDK: **macOS 10.12**
    - Deployment Target: **macOS 10.10**

While AlchemyRandom has only been tested on OS X with a beta version of Xcode, 
it should presumably work on iOS, tvOS, and watchOS as well.  It only depends on the 
the Swift standard library. 

## Installation

Install using the [Swift Package Manager](https://swift.org/package-manager/)

Add the project as a dependency to your Package.swift:

```swift
import PackageDescription

let package = Package(
    name: "MyProjectUsingAlchemyRandom",
    dependencies: [
        .Package(url: "https://github.com/chris-al-brown/alchemy-random", majorVersion: 0, minor: 2)
    ]
)
```

Then import `import AlchemyRandom`.

## Usage

Check out 'Demo.playground' for example usage.

## References

1. [Random Number Generators in Swift](http://www.cocoawithlove.com/blog/2016/05/19/random-numbers.html)

2. [xoroshiro+ / xorshift* / xorshift+ generators and the PRNG shootout](http://xoroshiro.di.unimi.it)

3. [Pseudo-random number generation](http://en.cppreference.com/w/cpp/numeric/random)

4. [rand(3) / random(3) / arc4random(3) / et al.](http://nshipster.com/random/)

5. [Using rand() (C/C++): Advice for the C standard library's rand() function.](http://eternallyconfuzzled.com/arts/jsw_art_rand.aspx)

6. [A Random Number Generator Based on the Combination of Four LCGs](http://dl.acm.org/citation.cfm?id=271660)

7. [Efficient Optimistic Parallel Simulations using Reverse Computation](http://dl.acm.org/citation.cfm?id=347828)

8. [Generating Poisson random values](http://www.johndcook.com/blog/2010/06/14/generating-poisson-random-values/)

## License

AlchemyRandom is released under the [MIT License](LICENSE.md).
