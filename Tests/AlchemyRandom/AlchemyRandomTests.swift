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
// AlchemyRandomTests.swift
// 06/27/2016
// -----------------------------------------------------------------------------

import XCTest
@testable import AlchemyRandom

/// ...
class AlchemyRandomTests: XCTestCase {

    /// ...
    func assayEntropySource<Source: EntropySource>(_ source: Source, sampleCount: Int) {
        let byteCount = 32
        var buffer = Array(repeating:UInt8(), count:byteCount)
        for _ in 0..<sampleCount {
            let byte32 = source.randomBytes() as UInt32
            XCTAssert(0 <= byte32 && byte32 <= UInt32.max, "\(source) randomBytes() as UInt32 failed")
            let byte64 = source.randomBytes() as UInt64
            XCTAssert(0 <= byte64 && byte64 <= UInt64.max, "\(source) randomBytes() as UInt64 failed")
            source.randomBytes(destination:&buffer, byteCount:byteCount)
            let mean = Double(buffer.reduce(0.0) {return $0 + Double($1)}) / Double(byteCount)
            XCTAssert(0 < mean && mean < 255, "\(source) randomBytes(destination:byteCount:) failed")
        }
    }
 
    /// ...
    func assayRandomNumberGeneratorBool<RNG: RandomNumberGenerator where RNG: Equatable>(_ rng: inout RNG, acceptance: Double, sampleCount: Int) {
        let bools = (0..<sampleCount).map {_ in return rng.nextBool()}
        let heads = (bools.filter() {return $0}).count
        let tails = bools.count - heads
        let bias = abs(heads - tails)
        let allowed = Int(acceptance * Double(sampleCount))
        XCTAssert(bias <= allowed, "\(rng) is Bernoulli biased: \(Double(bias) / Double(sampleCount)) > \(acceptance)")
    }
    
    /// ...
    func assayRandomNumberGeneratorDouble<RNG: RandomNumberGenerator where RNG: Equatable>(_ rng: inout RNG, sampleCount: Int) {
        let open = (0..<sampleCount).map {_ in return rng.nextDouble(in:0.0..<1.0)}
        XCTAssert(open.min() >= 0.0 && open.max() < 1.0, "\(rng) failed range test in [0.0, 1.0)")
        let closed = (0..<sampleCount).map {_ in return rng.nextDouble(in:0.0...1.0)}
        XCTAssert(closed.min() >= 0.0 && closed.max() <= 1.0, "\(rng) failed range test in [0.0, 1.0]")
    }
    
    /// ...
    func assayRandomNumberGeneratorInt<RNG: RandomNumberGenerator where RNG: Equatable>(_ rng: inout RNG, sampleCount: Int) {
        let open = (0..<sampleCount).map {_ in return rng.nextInt(in:0..<10)}
        XCTAssert(open.min() == 0 && open.max() < 10, "\(rng) failed range test in [0, 10)")
        let closed = (0..<sampleCount).map {_ in return rng.nextInt(in:0...10)}
        XCTAssert(closed.min() == 0 && closed.max() == 10, "\(rng) failed range test in [0, 10]")
    }

    /// ...
    func assayRandomNumberGeneratorPeriod<RNG: RandomNumberGenerator where RNG: Equatable>(_ rng: inout RNG, sampleCount: Int) {
        let rng1 = rng
        for i in 0..<sampleCount {
            _ = rng.nextBool()
            let rng2 = rng
            XCTAssert(rng1 != rng2, "\(rng1) repeated state after \(i) iterations")
        }
    }

    /// ...
    func assayRandomNumberGeneratorUtils() {
        XCTAssert(Xorshift128Plus.bitCast(seed:UInt32.min) == 0.0, "RandomNumberGenerator.bitCast(seed:\(UInt32.min)) failed")
        XCTAssert(1.0 - Xorshift128Plus.bitCast(seed:UInt32.max) == FLT_EPSILON, "RandomNumberGenerator.bitCast(seed:\(UInt32.max)) failed")
        XCTAssert(Xorshift128Plus.bitCast(seed:UInt64.min) == 0.0, "RandomNumberGenerator.bitCast(seed:\(UInt64.min)) failed")
        XCTAssert(1.0 - Xorshift128Plus.bitCast(seed:UInt64.max) == DBL_EPSILON, "RandomNumberGenerator.bitCast(seed:\(UInt64.max)) failed")
    }

    /// ...
    func assayRandomNumberGenerator<RNG: RandomNumberGenerator where RNG: Equatable>(_ rng: inout RNG, bias: Double, sampleCount: Int) {
        assayRandomNumberGeneratorPeriod(&rng, sampleCount:sampleCount)
        assayRandomNumberGeneratorBool(&rng, acceptance:bias, sampleCount:sampleCount)
        assayRandomNumberGeneratorDouble(&rng, sampleCount:sampleCount)
        assayRandomNumberGeneratorInt(&rng, sampleCount:sampleCount)
    }
    
    /// ...
    func testEntropySources() {
        assayEntropySource(Arc4Random(), sampleCount:50_000)
        assayEntropySource(DevURandom(), sampleCount:50_000)
    }
    
    /// ... 
    func testRandomNumberGenerators() {
        assayRandomNumberGeneratorUtils()
        do {
            /// LecuyerLCG4
            var lecuyer = LecuyerLCG4(source:Arc4Random())
            assayRandomNumberGenerator(&lecuyer, bias:0.02, sampleCount:25_000)
            lecuyer.seed = (1, 0, 0, 0)
            assayRandomNumberGenerator(&lecuyer, bias:0.02, sampleCount:25_000)
            lecuyer.seed = (0, 1, 0, 0)
            assayRandomNumberGenerator(&lecuyer, bias:0.02, sampleCount:25_000)
            lecuyer.seed = (0, 0, 1, 0)
            assayRandomNumberGenerator(&lecuyer, bias:0.02, sampleCount:25_000)
            lecuyer.seed = (0, 0, 0, 1)
            assayRandomNumberGenerator(&lecuyer, bias:0.02, sampleCount:25_000)
            lecuyer.seed = (UInt32.max, UInt32.max, UInt32.max, UInt32.max)
            assayRandomNumberGenerator(&lecuyer, bias:0.02, sampleCount:25_000)
            
            for _ in 0..<25_000 {
                lecuyer = LecuyerLCG4(source:Arc4Random())
                let value1 = lecuyer.nextDouble(in:0.0..<1.0)
                _ = lecuyer.nextDouble(in:0.0..<1.0)
                let value2 = lecuyer.previousDouble(in:0.0..<1.0)
                XCTAssert(value1 == value2, "\(lecuyer) failed reversibility test")
            }
        }
        do {
            /// MersenneTwister
            var twister = MersenneTwister(source:Arc4Random())
            assayRandomNumberGenerator(&twister, bias:0.01, sampleCount:50_000)
            twister = MersenneTwister(seed:0)
            assayRandomNumberGenerator(&twister, bias:0.01, sampleCount:50_000)
            twister = MersenneTwister(seed:UInt64.max)
            assayRandomNumberGenerator(&twister, bias:0.01, sampleCount:50_000)
        }
        do {
            /// Xorshift128+
            var xorshift = Xorshift128Plus(source:Arc4Random())
            assayRandomNumberGenerator(&xorshift, bias:0.01, sampleCount:50_000)
            xorshift.seed = (1, 0)
            assayRandomNumberGenerator(&xorshift, bias:0.01, sampleCount:50_000)
            xorshift.seed = (0, 1)
            assayRandomNumberGenerator(&xorshift, bias:0.01, sampleCount:50_000)
            xorshift.seed = (UInt64.max, UInt64.max)
            assayRandomNumberGenerator(&xorshift, bias:0.01, sampleCount:50_000)
        }
        do {
            /// Xoroshiro128+
            var xoroshiro = Xoroshiro128Plus(source:Arc4Random())
            assayRandomNumberGenerator(&xoroshiro, bias:0.01, sampleCount:50_000)
            xoroshiro.seed = (1, 0)
            assayRandomNumberGenerator(&xoroshiro, bias:0.01, sampleCount:50_000)
            xoroshiro.seed = (0, 1)
            assayRandomNumberGenerator(&xoroshiro, bias:0.01, sampleCount:50_000)
            xoroshiro.seed = (UInt64.max, UInt64.max)
            assayRandomNumberGenerator(&xoroshiro, bias:0.01, sampleCount:50_000)
        }
    }

    /// ...
    static var allTests : [(String, (AlchemyRandomTests) -> () throws -> Void)] {
        return [
            ("testEntropySources", testEntropySources),
            ("testRandomNumberGenerators", testRandomNumberGenerators)
        ]
    }
}
