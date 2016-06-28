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
let sampleCount = 100_000

/// ...
class AlchemyRandomTests: XCTestCase {

    /// ...
    func assayEntropySource<Source: EntropySource>(source: Source) {
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
    func testEntropySources() {
        assayEntropySource(source:Arc4Random())
        assayEntropySource(source:DevURandom())
    }

    /// ...
    static var allTests : [(String, (AlchemyRandomTests) -> () throws -> Void)] {
        return [
            ("testEntropySources", testEntropySources),
        ]
    }
}
