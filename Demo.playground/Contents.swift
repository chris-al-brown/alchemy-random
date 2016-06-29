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

import AlchemyRandom

/// Make a new entropy source
let source = Arc4Random()

/// Seed a new random number generator from the entropy source
var xorshift = Xorshift128Plus(source:source)

/// Generate some booleans
let booleans = [xorshift.nextBool(), xorshift.nextBool(), xorshift.nextBool()]

/// Generate some ints
let irange = 0...100
let ints = [xorshift.nextInt(in:irange), xorshift.nextInt(in:irange), xorshift.nextInt(in:irange)]

/// Generate some doubles
let drange = 0.0..<1.0
let doubles = [xorshift.nextDouble(in:drange), xorshift.nextDouble(in:drange), xorshift.nextDouble(in:drange)]

/// Make a reversible random number generator seeded from /dev/urandom
var lecuyer = LecuyerLCG4(source:DevURandom())

/// Generate some forward values
let f1 = lecuyer.nextDouble(in:drange)
let f2 = lecuyer.nextDouble(in:drange)
let f3 = lecuyer.nextDouble(in:drange)
let f4 = lecuyer.nextDouble(in:drange)
let f5 = lecuyer.nextDouble(in:drange)

/// Now reverse and generate values
let r4 = lecuyer.previousDouble(in:drange)
let r3 = lecuyer.previousDouble(in:drange)
let r2 = lecuyer.previousDouble(in:drange)
let r1 = lecuyer.previousDouble(in:drange)

/// Compare == "Magic"
r1 == f1
r2 == f2
r3 == f3
r4 == f4

/// Make a distribution and generate some numbers
var rng = MersenneTwister(source:source)
var uniform = Uniform()
uniform.randomSample(&rng)
uniform.randomSample(&rng)
uniform.randomSample(&rng)
uniform.randomSample(&rng)
uniform.randomSample(&rng)



