// -----------------------------------------------------------------------------
// Copyright (c) 2015 - 2016, Christopher A. Brown (chris-al-brown)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// AlchemyRandom
// RandomNumberGenerator.swift
// 06/27/2016
// -----------------------------------------------------------------------------

import Foundation

/// ...
public protocol RandomNumberGenerator {
    
    /// ...
    associatedtype Seed
    
    /// ...
    init<Source: EntropySource>(source: Source)

    /// ...
    mutating func nextBool() -> Bool

    /// ...
    mutating func nextDouble(in range: Range<Double>) -> Double

    /// ...
    mutating func nextInt(in range: CountableRange<Int>) -> Int

    /// ...
    var seed: Seed { get mutating set }
}

/// ...
extension RandomNumberGenerator {
    
    /// Returns a uniform value in the range [0.0, 1.0)
    public static func bitCast(seed: UInt32) -> Float {
        let kExponentBits = UInt32(0x3F800000)
        let kMantissaMask = UInt32(0x007FFFFF)
        let u = (seed & kMantissaMask) | kExponentBits
        return unsafeBitCast(u, to:Float.self) - 1.0
    }
    
    /// Returns a uniform value in the range [0.0, 1.0)
    public static func bitCast(seed: UInt64) -> Double {
        let kExponentBits = UInt64(0x3FF0000000000000)
        let kMantissaMask = UInt64(0x000FFFFFFFFFFFFF)
        let u = (seed & kMantissaMask) | kExponentBits
        return unsafeBitCast(u, to:Double.self) - 1.0
    }
    
    /// ...
    public static func describe(seed: UInt32, uppercase: Bool = false) -> String {
        return String(seed, radix:16, uppercase:uppercase)
    }

    /// ...
    public static func describe(seed: UInt64, uppercase: Bool = false) -> String {
        return String(seed, radix:16, uppercase:uppercase)
    }
    
    /// ...
    public mutating func nextDouble(in range: ClosedRange<Double>) -> Double {
        return nextDouble(in:range.lowerBound..<range.upperBound.nextUp)
    }
    
    /// ...
    public mutating func nextInt(in range: CountableClosedRange<Int>) -> Int {
        return nextInt(in:range.lowerBound..<range.upperBound.advanced(by:1))
    }
}

/// ...
public protocol ReversibleRandomNumberGenerator: RandomNumberGenerator {

    /// ...
    func previousBool() -> Bool
    
    /// ...
    func previousDouble(in range: Range<Double>) -> Double
    
    /// ...
    func previousInt(in range: Range<Int>) -> Int
}

/// ...
extension ReversibleRandomNumberGenerator {
    
    /// ...
    public mutating func previousDouble(in range: ClosedRange<Double>) -> Double {
        return previousDouble(in:range.lowerBound..<range.upperBound.nextUp)
    }
    
    /// ...
    public mutating func previousInt(in range: CountableClosedRange<Int>) -> Int {
        return previousInt(in:range.lowerBound..<range.upperBound.advanced(by:1))
    }
}

/// ...
public struct Xoroshiro128Plus: RandomNumberGenerator {

    /// ...
    public typealias Seed = (UInt64, UInt64)

    /// ...
    public init<Source: EntropySource>(source: Source) {
        var seed0: UInt64 = source.randomBytes()
        var seed1: UInt64 = source.randomBytes()
        while seed0 == 0 && seed1 == 0 {
            seed0 = source.randomBytes()
            seed1 = source.randomBytes()
        }
        self.init(seed0:seed0, seed1:seed1)
    }
    
    /// ...
    public init(seed0: UInt64, seed1: UInt64) {
        precondition(seed0 != 0 || seed1 != 0, "A 128-bit seed value of 0x0 is strictly not allowed")
        self.seed = (seed0, seed1)
    }
    
    /// ...
    public mutating func nextBool() -> Bool {
        return nextSeed() % 2 == 0
    }
    
    /// ...
    public mutating func nextDouble(in range: Range<Double>) -> Double {
        let min = range.lowerBound
        let max = range.upperBound
        return min + (max - min) * Xoroshiro128Plus.bitCast(seed:nextSeed())
    }
    
    /// ...
    public mutating func nextInt(in range: CountableRange<Int>) -> Int {
        let kLength = UInt64(range.count)
        let kEngine = UInt64.max
        let kExcess = kEngine % (kLength + 1)
        let kLimit = kEngine - kExcess
        var vSeed = nextSeed()
        while vSeed > kLimit {
            vSeed = nextSeed()
        }
        return Int(vSeed % kLength) + range.lowerBound
    }
    
    /// ...
    private mutating func nextSeed() -> UInt64 {
        let s0 = seed.0
        var s1 = seed.1
        s1 ^= s0
        seed.0 = ((s0 << 55) | (s0 >> 9)) ^ s1 ^ (s1 << 14)
        seed.1 = ((s1 << 36) | (s1 >> 28))
        return seed.0 &+ seed.1
    }
    
    /// ...
    public var seed: Seed
}

/// ...
extension Xoroshiro128Plus: CustomStringConvertible {
    
    /// ...
    public var description: String {
        let seed0 = Xoroshiro128Plus.describe(seed:seed.0)
        let seed1 = Xoroshiro128Plus.describe(seed:seed.1)
        return "Xoroshiro128Plus(0x\(seed0)\(seed1))"
    }
}

/// ...
extension Xoroshiro128Plus: Equatable {}
public func ==(lhs: Xoroshiro128Plus, rhs: Xoroshiro128Plus) -> Bool {
    return lhs.seed == rhs.seed
}

/// ...
public struct Xorshift128Plus: RandomNumberGenerator {
    
    /// ...
    public typealias Seed = (UInt64, UInt64)
    
    /// ...
    public init<Source: EntropySource>(source: Source) {
        var seed0: UInt64 = source.randomBytes()
        var seed1: UInt64 = source.randomBytes()
        while seed0 == 0 && seed1 == 0 {
            seed0 = source.randomBytes()
            seed1 = source.randomBytes()
        }
        self.init(seed0:seed0, seed1:seed1)
    }

    /// ...
    public init(seed0: UInt64, seed1: UInt64) {
        precondition(seed0 != 0 || seed1 != 0, "A 128-bit seed value of 0x0 is strictly not allowed")
        self.seed = (seed0, seed1)
    }

    /// ...
    public mutating func nextBool() -> Bool {
        return nextSeed() % 2 == 0
    }
    
    /// ...
    public mutating func nextDouble(in range: Range<Double>) -> Double {
        let min = range.lowerBound
        let max = range.upperBound
        return min + (max - min) * Xorshift128Plus.bitCast(seed:nextSeed())
    }
    
    /// ...
    public mutating func nextInt(in range: CountableRange<Int>) -> Int {
        let kLength = UInt64(range.count)
        let kEngine = UInt64.max
        let kExcess = kEngine % (kLength + 1)
        let kLimit = kEngine - kExcess
        var vSeed = nextSeed()
        while vSeed > kLimit {
            vSeed = nextSeed()
        }
        return Int(vSeed % kLength) + range.lowerBound
    }

    /// ...
    private mutating func nextSeed() -> UInt64 {
        var s1 = seed.0
        let s0 = seed.1
        seed.0 = s0
        s1 ^= (s1 << 23)
        seed.1 = s1 ^ s0 ^ (s1 >> 18) ^ (s0 >> 5)
        return seed.0 &+ seed.1
    }
    
    /// ...
    public var seed: Seed
}

/// ...
extension Xorshift128Plus: CustomStringConvertible {
    
    /// ...
    public var description: String {
        let seed0 = Xorshift128Plus.describe(seed:seed.0)
        let seed1 = Xorshift128Plus.describe(seed:seed.1)
        return "Xorshift128Plus(0x\(seed0)\(seed1))"
    }
}

/// ...
extension Xorshift128Plus: Equatable {}
public func ==(lhs: Xorshift128Plus, rhs: Xorshift128Plus) -> Bool {
    return lhs.seed == rhs.seed
}


