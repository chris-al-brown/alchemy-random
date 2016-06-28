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
// Demo.playground
// 06/23/2016
// -----------------------------------------------------------------------------

import Foundation
import AlchemyRandom

let arc4 = Arc4Random()
arc4.randomBytes() as UInt32
arc4.randomBytes() as UInt32
arc4.randomBytes() as UInt32
arc4.randomBytes() as UInt32

let dev = DevURandom()
dev.randomBytes() as UInt32
dev.randomBytes() as UInt32
dev.randomBytes() as UInt32
dev.randomBytes() as UInt32

var xorshift = Xorshift128Plus(source:dev)
xorshift.nextBool()
xorshift.nextBool()
xorshift.nextBool()
xorshift.nextBool()

var range = 0...10
var values: [Int: Int] = [:]
for i in range.lowerBound...range.upperBound {
    values[i] = 0
}
for i in 0..<1_000_000 {
    values[xorshift.nextInt(in:range)]! += 1
}
values

xorshift.nextDouble(in:0.0...1.0)
xorshift.nextDouble(in:0.0...1.0)
xorshift.nextDouble(in:0.0...1.0)
xorshift.nextDouble(in:0.0...1.0)
xorshift.nextDouble(in:0.0...1.0)
xorshift.nextDouble(in:0.0...1.0)
xorshift.nextDouble(in:0.0...1.0)
xorshift.nextDouble(in:0.0...1.0)
xorshift.nextDouble(in:0.0...1.0)
xorshift.nextDouble(in:0.0...1.0)

var lecuyer = LecuyerLCG4(source:DevURandom())
lecuyer.nextDouble(in:0.0..<1.0)
lecuyer.nextDouble(in:0.0..<1.0)
lecuyer.previousDouble(in:0.0..<1.0)
lecuyer.previousDouble(in:0.0..<1.0)
