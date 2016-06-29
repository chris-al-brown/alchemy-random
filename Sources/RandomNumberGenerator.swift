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
        seed.0 = UInt32(LecuyerLCG4.forward.0 &* UInt64(seed.0) % LecuyerLCG4.modulus.0)
        seed.1 = UInt32(LecuyerLCG4.forward.1 &* UInt64(seed.1) % LecuyerLCG4.modulus.1)
        seed.2 = UInt32(LecuyerLCG4.forward.2 &* UInt64(seed.2) % LecuyerLCG4.modulus.2)
        seed.3 = UInt32(LecuyerLCG4.forward.3 &* UInt64(seed.3) % LecuyerLCG4.modulus.3)
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
        seed.0 = UInt32(LecuyerLCG4.reverse.0 &* UInt64(seed.0) % LecuyerLCG4.modulus.0)
        seed.1 = UInt32(LecuyerLCG4.reverse.1 &* UInt64(seed.1) % LecuyerLCG4.modulus.1)
        seed.2 = UInt32(LecuyerLCG4.reverse.2 &* UInt64(seed.2) % LecuyerLCG4.modulus.2)
        seed.3 = UInt32(LecuyerLCG4.reverse.3 &* UInt64(seed.3) % LecuyerLCG4.modulus.3)
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
public struct MersenneTwister: RandomNumberGenerator {
    
    /// ...
    public typealias Seed = (
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64
    )
    
    /// ...
    public static let seedCount: Int = 312
    
    /// ...
    public init<Source: EntropySource>(source: Source) {
        self.init(seed:source.randomBytes())
    }
    
    /// ...
    public init(seed: UInt64) {
        self.seedIndex = MersenneTwister.seedCount
        self.seed = (
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        )
        withSeed { state in
            state[0] = seed
            for i in 1..<MersenneTwister.seedCount {
                state[i] = 6364136223846793005 &* (state[i &- 1] ^ (state[i &- 1] >> 62)) &+ UInt64(i)
            }
        }
    }
    
    /// ...
    public mutating func nextBool() -> Bool {
        return nextSeed() % 2 == 0
    }
    
    /// ...
    public mutating func nextDouble(in range: Range<Double>) -> Double {
        let min = range.lowerBound
        let max = range.upperBound
        return min + (max - min) * MersenneTwister.bitCast(seed:nextSeed())
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
        if seedIndex == MersenneTwister.seedCount {
            twistSeed()
        }
        
        var result = seedAt(index:seedIndex)
        result ^= (result >> 29) & 0x5555555555555555
        result ^= (result << 17) & 0x71D67FFFEDA60000
        result ^= (result << 37) & 0xFFF7EEE000000000
        result ^=  result >> 43
        
        seedIndex = seedIndex &+ 1
        return result
    }

    /// ...
    private mutating func seedAt(index: Int) -> UInt64 {
        return withUnsafePointer(&seed) { ptr -> UInt64 in
            return UnsafePointer<UInt64>(ptr)[index]
        }
    }
    
    private mutating func twistSeed() {
        withSeed { state in
            let n = MersenneTwister.seedCount
            let m = n / 2
            let a: UInt64 = 0xB5026F5AA96619E9
            let lowerMask: UInt64 = (1 << 31) - 1
            let upperMask: UInt64 = ~lowerMask
            var (i, j, stateM) = (0, m, state[m])
            repeat {
                let x1 = (state[i] & upperMask) | (state[i &+ 1] & lowerMask)
                state[i] = state[i &+ m] ^ (x1 >> 1) ^ ((state[i &+ 1] & 1) &* a)
                let x2 = (state[j] & upperMask) | (state[j &+ 1] & lowerMask)
                state[j] = state[j &- m] ^ (x2 >> 1) ^ ((state[j &+ 1] & 1) &* a)
                (i, j) = (i &+ 1, j &+ 1)
            } while i != m &- 1
            
            let x3 = (state[m &- 1] & upperMask) | (stateM & lowerMask)
            state[m &- 1] = state[n &- 1] ^ (x3 >> 1) ^ ((stateM & 1) &* a)
            let x4 = (state[n &- 1] & upperMask) | (state[0] & lowerMask)
            state[n &- 1] = state[m &- 1] ^ (x4 >> 1) ^ ((state[0] & 1) &* a)
        }
        seedIndex = 0
    }

    /// ...
    private mutating func withSeed(f: @noescape (UnsafeMutablePointer<UInt64>) -> Void) {
        withUnsafeMutablePointer(&seed) { ptr in
            f(UnsafeMutablePointer<UInt64>(ptr))
        }
    }
    
    /// ...
    private var seedIndex: Int

    /// ...
    public var seed: Seed
}

/// ...
extension MersenneTwister: CustomStringConvertible {
    
    /// ...
    public var description: String {
        var _seed = seed
        let _seedi = withUnsafePointer(&_seed) { ptr -> UInt64 in
            return UnsafePointer<UInt64>(ptr)[seedIndex]
        }
        let seedi = MersenneTwister.describe(seed:_seedi)
        let index = String(seedIndex, radix:16, uppercase:false)
        return "MersenneTwister(0x\(index)|0x\(seedi))"
    }
}

/// ...
extension MersenneTwister: Equatable {}
public func ==(lhs: MersenneTwister, rhs: MersenneTwister) -> Bool {
    if lhs.seed.0 != rhs.seed.0 { return false }
    if lhs.seed.1 != rhs.seed.1 { return false }
    if lhs.seed.2 != rhs.seed.2 { return false }
    if lhs.seed.3 != rhs.seed.3 { return false }
    if lhs.seed.4 != rhs.seed.4 { return false }
    if lhs.seed.5 != rhs.seed.5 { return false }
    if lhs.seed.6 != rhs.seed.6 { return false }
    if lhs.seed.7 != rhs.seed.7 { return false }
    if lhs.seed.8 != rhs.seed.8 { return false }
    if lhs.seed.9 != rhs.seed.9 { return false }
    if lhs.seed.10 != rhs.seed.10 { return false }
    if lhs.seed.11 != rhs.seed.11 { return false }
    if lhs.seed.12 != rhs.seed.12 { return false }
    if lhs.seed.13 != rhs.seed.13 { return false }
    if lhs.seed.14 != rhs.seed.14 { return false }
    if lhs.seed.15 != rhs.seed.15 { return false }
    if lhs.seed.16 != rhs.seed.16 { return false }
    if lhs.seed.17 != rhs.seed.17 { return false }
    if lhs.seed.18 != rhs.seed.18 { return false }
    if lhs.seed.19 != rhs.seed.19 { return false }
    if lhs.seed.20 != rhs.seed.20 { return false }
    if lhs.seed.21 != rhs.seed.21 { return false }
    if lhs.seed.22 != rhs.seed.22 { return false }
    if lhs.seed.23 != rhs.seed.23 { return false }
    if lhs.seed.24 != rhs.seed.24 { return false }
    if lhs.seed.25 != rhs.seed.25 { return false }
    if lhs.seed.26 != rhs.seed.26 { return false }
    if lhs.seed.27 != rhs.seed.27 { return false }
    if lhs.seed.28 != rhs.seed.28 { return false }
    if lhs.seed.29 != rhs.seed.29 { return false }
    if lhs.seed.30 != rhs.seed.30 { return false }
    if lhs.seed.31 != rhs.seed.31 { return false }
    if lhs.seed.32 != rhs.seed.32 { return false }
    if lhs.seed.33 != rhs.seed.33 { return false }
    if lhs.seed.34 != rhs.seed.34 { return false }
    if lhs.seed.35 != rhs.seed.35 { return false }
    if lhs.seed.36 != rhs.seed.36 { return false }
    if lhs.seed.37 != rhs.seed.37 { return false }
    if lhs.seed.38 != rhs.seed.38 { return false }
    if lhs.seed.39 != rhs.seed.39 { return false }
    if lhs.seed.40 != rhs.seed.40 { return false }
    if lhs.seed.41 != rhs.seed.41 { return false }
    if lhs.seed.42 != rhs.seed.42 { return false }
    if lhs.seed.43 != rhs.seed.43 { return false }
    if lhs.seed.44 != rhs.seed.44 { return false }
    if lhs.seed.45 != rhs.seed.45 { return false }
    if lhs.seed.46 != rhs.seed.46 { return false }
    if lhs.seed.47 != rhs.seed.47 { return false }
    if lhs.seed.48 != rhs.seed.48 { return false }
    if lhs.seed.49 != rhs.seed.49 { return false }
    if lhs.seed.50 != rhs.seed.50 { return false }
    if lhs.seed.51 != rhs.seed.51 { return false }
    if lhs.seed.52 != rhs.seed.52 { return false }
    if lhs.seed.53 != rhs.seed.53 { return false }
    if lhs.seed.54 != rhs.seed.54 { return false }
    if lhs.seed.55 != rhs.seed.55 { return false }
    if lhs.seed.56 != rhs.seed.56 { return false }
    if lhs.seed.57 != rhs.seed.57 { return false }
    if lhs.seed.58 != rhs.seed.58 { return false }
    if lhs.seed.59 != rhs.seed.59 { return false }
    if lhs.seed.60 != rhs.seed.60 { return false }
    if lhs.seed.61 != rhs.seed.61 { return false }
    if lhs.seed.62 != rhs.seed.62 { return false }
    if lhs.seed.63 != rhs.seed.63 { return false }
    if lhs.seed.64 != rhs.seed.64 { return false }
    if lhs.seed.65 != rhs.seed.65 { return false }
    if lhs.seed.66 != rhs.seed.66 { return false }
    if lhs.seed.67 != rhs.seed.67 { return false }
    if lhs.seed.68 != rhs.seed.68 { return false }
    if lhs.seed.69 != rhs.seed.69 { return false }
    if lhs.seed.70 != rhs.seed.70 { return false }
    if lhs.seed.71 != rhs.seed.71 { return false }
    if lhs.seed.72 != rhs.seed.72 { return false }
    if lhs.seed.73 != rhs.seed.73 { return false }
    if lhs.seed.74 != rhs.seed.74 { return false }
    if lhs.seed.75 != rhs.seed.75 { return false }
    if lhs.seed.76 != rhs.seed.76 { return false }
    if lhs.seed.77 != rhs.seed.77 { return false }
    if lhs.seed.78 != rhs.seed.78 { return false }
    if lhs.seed.79 != rhs.seed.79 { return false }
    if lhs.seed.80 != rhs.seed.80 { return false }
    if lhs.seed.81 != rhs.seed.81 { return false }
    if lhs.seed.82 != rhs.seed.82 { return false }
    if lhs.seed.83 != rhs.seed.83 { return false }
    if lhs.seed.84 != rhs.seed.84 { return false }
    if lhs.seed.85 != rhs.seed.85 { return false }
    if lhs.seed.86 != rhs.seed.86 { return false }
    if lhs.seed.87 != rhs.seed.87 { return false }
    if lhs.seed.88 != rhs.seed.88 { return false }
    if lhs.seed.89 != rhs.seed.89 { return false }
    if lhs.seed.90 != rhs.seed.90 { return false }
    if lhs.seed.91 != rhs.seed.91 { return false }
    if lhs.seed.92 != rhs.seed.92 { return false }
    if lhs.seed.93 != rhs.seed.93 { return false }
    if lhs.seed.94 != rhs.seed.94 { return false }
    if lhs.seed.95 != rhs.seed.95 { return false }
    if lhs.seed.96 != rhs.seed.96 { return false }
    if lhs.seed.97 != rhs.seed.97 { return false }
    if lhs.seed.98 != rhs.seed.98 { return false }
    if lhs.seed.99 != rhs.seed.99 { return false }
    if lhs.seed.100 != rhs.seed.100 { return false }
    if lhs.seed.101 != rhs.seed.101 { return false }
    if lhs.seed.102 != rhs.seed.102 { return false }
    if lhs.seed.103 != rhs.seed.103 { return false }
    if lhs.seed.104 != rhs.seed.104 { return false }
    if lhs.seed.105 != rhs.seed.105 { return false }
    if lhs.seed.106 != rhs.seed.106 { return false }
    if lhs.seed.107 != rhs.seed.107 { return false }
    if lhs.seed.108 != rhs.seed.108 { return false }
    if lhs.seed.109 != rhs.seed.109 { return false }
    if lhs.seed.110 != rhs.seed.110 { return false }
    if lhs.seed.111 != rhs.seed.111 { return false }
    if lhs.seed.112 != rhs.seed.112 { return false }
    if lhs.seed.113 != rhs.seed.113 { return false }
    if lhs.seed.114 != rhs.seed.114 { return false }
    if lhs.seed.115 != rhs.seed.115 { return false }
    if lhs.seed.116 != rhs.seed.116 { return false }
    if lhs.seed.117 != rhs.seed.117 { return false }
    if lhs.seed.118 != rhs.seed.118 { return false }
    if lhs.seed.119 != rhs.seed.119 { return false }
    if lhs.seed.120 != rhs.seed.120 { return false }
    if lhs.seed.121 != rhs.seed.121 { return false }
    if lhs.seed.122 != rhs.seed.122 { return false }
    if lhs.seed.123 != rhs.seed.123 { return false }
    if lhs.seed.124 != rhs.seed.124 { return false }
    if lhs.seed.125 != rhs.seed.125 { return false }
    if lhs.seed.126 != rhs.seed.126 { return false }
    if lhs.seed.127 != rhs.seed.127 { return false }
    if lhs.seed.128 != rhs.seed.128 { return false }
    if lhs.seed.129 != rhs.seed.129 { return false }
    if lhs.seed.130 != rhs.seed.130 { return false }
    if lhs.seed.131 != rhs.seed.131 { return false }
    if lhs.seed.132 != rhs.seed.132 { return false }
    if lhs.seed.133 != rhs.seed.133 { return false }
    if lhs.seed.134 != rhs.seed.134 { return false }
    if lhs.seed.135 != rhs.seed.135 { return false }
    if lhs.seed.136 != rhs.seed.136 { return false }
    if lhs.seed.137 != rhs.seed.137 { return false }
    if lhs.seed.138 != rhs.seed.138 { return false }
    if lhs.seed.139 != rhs.seed.139 { return false }
    if lhs.seed.140 != rhs.seed.140 { return false }
    if lhs.seed.141 != rhs.seed.141 { return false }
    if lhs.seed.142 != rhs.seed.142 { return false }
    if lhs.seed.143 != rhs.seed.143 { return false }
    if lhs.seed.144 != rhs.seed.144 { return false }
    if lhs.seed.145 != rhs.seed.145 { return false }
    if lhs.seed.146 != rhs.seed.146 { return false }
    if lhs.seed.147 != rhs.seed.147 { return false }
    if lhs.seed.148 != rhs.seed.148 { return false }
    if lhs.seed.149 != rhs.seed.149 { return false }
    if lhs.seed.150 != rhs.seed.150 { return false }
    if lhs.seed.151 != rhs.seed.151 { return false }
    if lhs.seed.152 != rhs.seed.152 { return false }
    if lhs.seed.153 != rhs.seed.153 { return false }
    if lhs.seed.154 != rhs.seed.154 { return false }
    if lhs.seed.155 != rhs.seed.155 { return false }
    if lhs.seed.156 != rhs.seed.156 { return false }
    if lhs.seed.157 != rhs.seed.157 { return false }
    if lhs.seed.158 != rhs.seed.158 { return false }
    if lhs.seed.159 != rhs.seed.159 { return false }
    if lhs.seed.160 != rhs.seed.160 { return false }
    if lhs.seed.161 != rhs.seed.161 { return false }
    if lhs.seed.162 != rhs.seed.162 { return false }
    if lhs.seed.163 != rhs.seed.163 { return false }
    if lhs.seed.164 != rhs.seed.164 { return false }
    if lhs.seed.165 != rhs.seed.165 { return false }
    if lhs.seed.166 != rhs.seed.166 { return false }
    if lhs.seed.167 != rhs.seed.167 { return false }
    if lhs.seed.168 != rhs.seed.168 { return false }
    if lhs.seed.169 != rhs.seed.169 { return false }
    if lhs.seed.170 != rhs.seed.170 { return false }
    if lhs.seed.171 != rhs.seed.171 { return false }
    if lhs.seed.172 != rhs.seed.172 { return false }
    if lhs.seed.173 != rhs.seed.173 { return false }
    if lhs.seed.174 != rhs.seed.174 { return false }
    if lhs.seed.175 != rhs.seed.175 { return false }
    if lhs.seed.176 != rhs.seed.176 { return false }
    if lhs.seed.177 != rhs.seed.177 { return false }
    if lhs.seed.178 != rhs.seed.178 { return false }
    if lhs.seed.179 != rhs.seed.179 { return false }
    if lhs.seed.180 != rhs.seed.180 { return false }
    if lhs.seed.181 != rhs.seed.181 { return false }
    if lhs.seed.182 != rhs.seed.182 { return false }
    if lhs.seed.183 != rhs.seed.183 { return false }
    if lhs.seed.184 != rhs.seed.184 { return false }
    if lhs.seed.185 != rhs.seed.185 { return false }
    if lhs.seed.186 != rhs.seed.186 { return false }
    if lhs.seed.187 != rhs.seed.187 { return false }
    if lhs.seed.188 != rhs.seed.188 { return false }
    if lhs.seed.189 != rhs.seed.189 { return false }
    if lhs.seed.190 != rhs.seed.190 { return false }
    if lhs.seed.191 != rhs.seed.191 { return false }
    if lhs.seed.192 != rhs.seed.192 { return false }
    if lhs.seed.193 != rhs.seed.193 { return false }
    if lhs.seed.194 != rhs.seed.194 { return false }
    if lhs.seed.195 != rhs.seed.195 { return false }
    if lhs.seed.196 != rhs.seed.196 { return false }
    if lhs.seed.197 != rhs.seed.197 { return false }
    if lhs.seed.198 != rhs.seed.198 { return false }
    if lhs.seed.199 != rhs.seed.199 { return false }
    if lhs.seed.200 != rhs.seed.200 { return false }
    if lhs.seed.201 != rhs.seed.201 { return false }
    if lhs.seed.202 != rhs.seed.202 { return false }
    if lhs.seed.203 != rhs.seed.203 { return false }
    if lhs.seed.204 != rhs.seed.204 { return false }
    if lhs.seed.205 != rhs.seed.205 { return false }
    if lhs.seed.206 != rhs.seed.206 { return false }
    if lhs.seed.207 != rhs.seed.207 { return false }
    if lhs.seed.208 != rhs.seed.208 { return false }
    if lhs.seed.209 != rhs.seed.209 { return false }
    if lhs.seed.210 != rhs.seed.210 { return false }
    if lhs.seed.211 != rhs.seed.211 { return false }
    if lhs.seed.212 != rhs.seed.212 { return false }
    if lhs.seed.213 != rhs.seed.213 { return false }
    if lhs.seed.214 != rhs.seed.214 { return false }
    if lhs.seed.215 != rhs.seed.215 { return false }
    if lhs.seed.216 != rhs.seed.216 { return false }
    if lhs.seed.217 != rhs.seed.217 { return false }
    if lhs.seed.218 != rhs.seed.218 { return false }
    if lhs.seed.219 != rhs.seed.219 { return false }
    if lhs.seed.220 != rhs.seed.220 { return false }
    if lhs.seed.221 != rhs.seed.221 { return false }
    if lhs.seed.222 != rhs.seed.222 { return false }
    if lhs.seed.223 != rhs.seed.223 { return false }
    if lhs.seed.224 != rhs.seed.224 { return false }
    if lhs.seed.225 != rhs.seed.225 { return false }
    if lhs.seed.226 != rhs.seed.226 { return false }
    if lhs.seed.227 != rhs.seed.227 { return false }
    if lhs.seed.228 != rhs.seed.228 { return false }
    if lhs.seed.229 != rhs.seed.229 { return false }
    if lhs.seed.230 != rhs.seed.230 { return false }
    if lhs.seed.231 != rhs.seed.231 { return false }
    if lhs.seed.232 != rhs.seed.232 { return false }
    if lhs.seed.233 != rhs.seed.233 { return false }
    if lhs.seed.234 != rhs.seed.234 { return false }
    if lhs.seed.235 != rhs.seed.235 { return false }
    if lhs.seed.236 != rhs.seed.236 { return false }
    if lhs.seed.237 != rhs.seed.237 { return false }
    if lhs.seed.238 != rhs.seed.238 { return false }
    if lhs.seed.239 != rhs.seed.239 { return false }
    if lhs.seed.240 != rhs.seed.240 { return false }
    if lhs.seed.241 != rhs.seed.241 { return false }
    if lhs.seed.242 != rhs.seed.242 { return false }
    if lhs.seed.243 != rhs.seed.243 { return false }
    if lhs.seed.244 != rhs.seed.244 { return false }
    if lhs.seed.245 != rhs.seed.245 { return false }
    if lhs.seed.246 != rhs.seed.246 { return false }
    if lhs.seed.247 != rhs.seed.247 { return false }
    if lhs.seed.248 != rhs.seed.248 { return false }
    if lhs.seed.249 != rhs.seed.249 { return false }
    if lhs.seed.250 != rhs.seed.250 { return false }
    if lhs.seed.251 != rhs.seed.251 { return false }
    if lhs.seed.252 != rhs.seed.252 { return false }
    if lhs.seed.253 != rhs.seed.253 { return false }
    if lhs.seed.254 != rhs.seed.254 { return false }
    if lhs.seed.255 != rhs.seed.255 { return false }
    if lhs.seed.256 != rhs.seed.256 { return false }
    if lhs.seed.257 != rhs.seed.257 { return false }
    if lhs.seed.258 != rhs.seed.258 { return false }
    if lhs.seed.259 != rhs.seed.259 { return false }
    if lhs.seed.260 != rhs.seed.260 { return false }
    if lhs.seed.261 != rhs.seed.261 { return false }
    if lhs.seed.262 != rhs.seed.262 { return false }
    if lhs.seed.263 != rhs.seed.263 { return false }
    if lhs.seed.264 != rhs.seed.264 { return false }
    if lhs.seed.265 != rhs.seed.265 { return false }
    if lhs.seed.266 != rhs.seed.266 { return false }
    if lhs.seed.267 != rhs.seed.267 { return false }
    if lhs.seed.268 != rhs.seed.268 { return false }
    if lhs.seed.269 != rhs.seed.269 { return false }
    if lhs.seed.270 != rhs.seed.270 { return false }
    if lhs.seed.271 != rhs.seed.271 { return false }
    if lhs.seed.272 != rhs.seed.272 { return false }
    if lhs.seed.273 != rhs.seed.273 { return false }
    if lhs.seed.274 != rhs.seed.274 { return false }
    if lhs.seed.275 != rhs.seed.275 { return false }
    if lhs.seed.276 != rhs.seed.276 { return false }
    if lhs.seed.277 != rhs.seed.277 { return false }
    if lhs.seed.278 != rhs.seed.278 { return false }
    if lhs.seed.279 != rhs.seed.279 { return false }
    if lhs.seed.280 != rhs.seed.280 { return false }
    if lhs.seed.281 != rhs.seed.281 { return false }
    if lhs.seed.282 != rhs.seed.282 { return false }
    if lhs.seed.283 != rhs.seed.283 { return false }
    if lhs.seed.284 != rhs.seed.284 { return false }
    if lhs.seed.285 != rhs.seed.285 { return false }
    if lhs.seed.286 != rhs.seed.286 { return false }
    if lhs.seed.287 != rhs.seed.287 { return false }
    if lhs.seed.288 != rhs.seed.288 { return false }
    if lhs.seed.289 != rhs.seed.289 { return false }
    if lhs.seed.290 != rhs.seed.290 { return false }
    if lhs.seed.291 != rhs.seed.291 { return false }
    if lhs.seed.292 != rhs.seed.292 { return false }
    if lhs.seed.293 != rhs.seed.293 { return false }
    if lhs.seed.294 != rhs.seed.294 { return false }
    if lhs.seed.295 != rhs.seed.295 { return false }
    if lhs.seed.296 != rhs.seed.296 { return false }
    if lhs.seed.297 != rhs.seed.297 { return false }
    if lhs.seed.298 != rhs.seed.298 { return false }
    if lhs.seed.299 != rhs.seed.299 { return false }
    if lhs.seed.300 != rhs.seed.300 { return false }
    if lhs.seed.301 != rhs.seed.301 { return false }
    if lhs.seed.302 != rhs.seed.302 { return false }
    if lhs.seed.303 != rhs.seed.303 { return false }
    if lhs.seed.304 != rhs.seed.304 { return false }
    if lhs.seed.305 != rhs.seed.305 { return false }
    if lhs.seed.306 != rhs.seed.306 { return false }
    if lhs.seed.307 != rhs.seed.307 { return false }
    if lhs.seed.308 != rhs.seed.308 { return false }
    if lhs.seed.309 != rhs.seed.309 { return false }
    if lhs.seed.310 != rhs.seed.310 { return false }
    if lhs.seed.311 != rhs.seed.311 { return false }
    return true
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


