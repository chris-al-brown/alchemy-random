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
    mutating func previousBool() -> Bool
    
    /// ...
    mutating func previousDouble(in range: Range<Double>) -> Double
    
    /// ...
    mutating func previousInt(in range: CountableRange<Int>) -> Int
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
public struct LecuyerLCG4: ReversibleRandomNumberGenerator {

    /// ...
    public typealias Seed = (UInt32, UInt32, UInt32, UInt32)
    
    /// ... 
    public static let forward: (UInt64, UInt64, UInt64, UInt64) = (
        45991,
        207707,
        138556,
        49689
    )

    /// ...
    public static let reverse: (UInt64, UInt64, UInt64, UInt64) = (
        1441196816,
        1463744518,
        499766181,
        660421676
    )

    /// ...
    public static let modulus: (UInt64, UInt64, UInt64, UInt64) = (
        2147483647,
        2147483543,
        2147483423,
        2147483323
    )

    /// ...
    public static let normalization: (Double, Double, Double, Double) = (
        4.65661287524579692e-10,
        4.65661310075985993e-10,
        4.65661336096842131e-10,
        4.65661357780891134e-10
    )
    
    /// ...
    public init<Source: EntropySource>(source: Source) {
        var seed0: UInt32 = source.randomBytes()
        var seed1: UInt32 = source.randomBytes()
        var seed2: UInt32 = source.randomBytes()
        var seed3: UInt32 = source.randomBytes()
        while seed0 == 0 && seed1 == 0 && seed2 == 0 && seed3 == 0 {
            seed0 = source.randomBytes()
            seed1 = source.randomBytes()
            seed2 = source.randomBytes()
            seed3 = source.randomBytes()
        }
        self.init(seed0:seed0, seed1:seed1, seed2:seed2, seed3:seed3)
    }

    /// ...
    public init(seed0: UInt32, seed1: UInt32, seed2: UInt32, seed3: UInt32) {
        precondition(max(seed0, seed1, seed2, seed3) > 0, "A 128-bit seed value of 0x0 is strictly not allowed")
        self.seed = (seed0, seed1, seed2, seed3)
    }
    
    /// ...
    private func currentDouble() -> Double {
        var u: Double = 0.0
        u = u + LecuyerLCG4.normalization.0 * Double(seed.0)
        u = u - LecuyerLCG4.normalization.1 * Double(seed.1)
        if u < 0.0 {
            u = u + 1.0
        }
        u = u + LecuyerLCG4.normalization.2 * Double(seed.2)
        if u >= 1.0 {
            u = u - 1.0
        }
        u = u - LecuyerLCG4.normalization.3 * Double(seed.3)
        if u < 0.0 {
            u = u + 1.0
        }
        return u
    }
    
    /// ...
    private func currentSeed() -> UInt64 {
        return unsafeBitCast(currentDouble() + 1.0, to:UInt64.self) & UInt64(0x000FFFFFFFFFFFFF)
    }
    
    /// ...
    public mutating func nextBool() -> Bool {
        nextSeed()
        return currentDouble() < 0.5
    }
    
    /// ...
    public mutating func nextDouble(in range: Range<Double>) -> Double {
        nextSeed()
        let min = range.lowerBound
        let max = range.upperBound
        return min + (max - min) * currentDouble()
    }
    
    /// ...
    public mutating func nextInt(in range: CountableRange<Int>) -> Int {
        let kLength = UInt64(range.count)
        let kEngine = UInt64(0x000FFFFFFFFFFFFF)
        let kExcess = kEngine % (kLength + 1)
        let kLimit = kEngine - kExcess
        nextSeed()
        var vSeed = currentSeed()
        while vSeed > kLimit {
            nextSeed()
            vSeed = currentSeed()
        }
        return Int(vSeed % kLength) + range.lowerBound
    }

    /// ...
    private mutating func nextSeed() {
        seed.0 = UInt32(LecuyerLCG4.forward.0 * UInt64(seed.0) % LecuyerLCG4.modulus.0)
        seed.1 = UInt32(LecuyerLCG4.forward.1 * UInt64(seed.1) % LecuyerLCG4.modulus.1)
        seed.2 = UInt32(LecuyerLCG4.forward.2 * UInt64(seed.2) % LecuyerLCG4.modulus.2)
        seed.3 = UInt32(LecuyerLCG4.forward.3 * UInt64(seed.3) % LecuyerLCG4.modulus.3)
    }

    /// ...
    public mutating func previousBool() -> Bool {
        previousSeed()
        return currentDouble() < 0.5
    }
    
    /// ...
    public mutating func previousDouble(in range: Range<Double>) -> Double {
        previousSeed()
        let min = range.lowerBound
        let max = range.upperBound
        return min + (max - min) * currentDouble()
    }
    
    /// ...
    public mutating func previousInt(in range: CountableRange<Int>) -> Int {
        let kLength = UInt64(range.count)
        let kEngine = UInt64(0x000FFFFFFFFFFFFF)
        let kExcess = kEngine % (kLength + 1)
        let kLimit = kEngine - kExcess
        previousSeed()
        var vSeed = currentSeed()
        while vSeed > kLimit {
            previousSeed()
            vSeed = currentSeed()
        }
        return Int(vSeed % kLength) + range.lowerBound
    }

    /// ...
    private mutating func previousSeed() {
        seed.0 = UInt32(LecuyerLCG4.reverse.0 * UInt64(seed.0) % LecuyerLCG4.modulus.0)
        seed.1 = UInt32(LecuyerLCG4.reverse.1 * UInt64(seed.1) % LecuyerLCG4.modulus.1)
        seed.2 = UInt32(LecuyerLCG4.reverse.2 * UInt64(seed.2) % LecuyerLCG4.modulus.2)
        seed.3 = UInt32(LecuyerLCG4.reverse.3 * UInt64(seed.3) % LecuyerLCG4.modulus.3)
    }
    
    /// ...
    public var seed: Seed
}

/// ...
extension LecuyerLCG4: CustomStringConvertible {
    
    /// ...
    public var description: String {
        let seed0 = LecuyerLCG4.describe(seed:seed.0)
        let seed1 = LecuyerLCG4.describe(seed:seed.1)
        let seed2 = LecuyerLCG4.describe(seed:seed.2)
        let seed3 = LecuyerLCG4.describe(seed:seed.3)
        return "LecuyerLCG4(0x\(seed0)|0x\(seed1)|0x\(seed2)|0x\(seed3))"
    }
}

/// ...
extension LecuyerLCG4: Equatable {}
public func ==(lhs: LecuyerLCG4, rhs: LecuyerLCG4) -> Bool {
    return lhs.seed == rhs.seed
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
        precondition(max(seed0, seed1) > 0, "A 128-bit seed value of 0x0 is strictly not allowed")
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
        return "Xoroshiro128Plus(0x\(seed0)|0x\(seed1))"
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
        precondition(max(seed0, seed1) > 0, "A 128-bit seed value of 0x0 is strictly not allowed")
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
        return "Xorshift128Plus(0x\(seed0)|0x\(seed1))"
    }
}

/// ...
extension Xorshift128Plus: Equatable {}
public func ==(lhs: Xorshift128Plus, rhs: Xorshift128Plus) -> Bool {
    return lhs.seed == rhs.seed
}


