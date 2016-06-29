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
// Distribution.swift
// 06/29/2016
// -----------------------------------------------------------------------------

import Foundation

/// ... 
public protocol Distribution {
    
    /// ...
    associatedtype Sample
    
    /// ...
    mutating func random<RNG: RandomNumberGenerator>(_ rng: inout RNG) -> Sample
}

/// ...
public struct Gaussian: Distribution {
    
    /// ...
    public init(mean: Double = 0.0, stddev: Double = 1.0) {
        self.mean = mean
        self.stddev = stddev
        self._z0 = 0.0
        self._z1 = 0.0
        self._generate = false
    }
    
    /// ...
    public mutating func random<RNG: RandomNumberGenerator>(_ rng: inout RNG) -> Double {
        _generate = !_generate
        if !_generate {
            return _z1 * stddev + mean
        }
        var u1: Double = 0.0
        var u2: Double = 0.0
        repeat {
            u1 = rng.nextDouble()
            u2 = rng.nextDouble()
        } while u1 <= DBL_EPSILON
        _z0 = sqrt(-2.0 * log(u1)) * cos(2.0 * M_PI * u2)
        _z1 = sqrt(-2.0 * log(u1)) * sin(2.0 * M_PI * u2)
        return _z0 * stddev + mean
    }
    
    /// ...
    public var mean: Double
    
    /// ...
    public var stddev: Double
    
    /// ...
    private var _z0: Double
    private var _z1: Double
    private var _generate: Bool
}

/// ...
extension Gaussian: CustomStringConvertible {
    
    /// ...
    public var description: String {
        return "Gaussian(μ = \(mean), σ = \(stddev))"
    }
}

/// ...
public struct Uniform: Distribution {
    
    /// ...
    public typealias Sample = Double
    
    /// ...
    public init(bounds: Range<Double>) {
        self.bounds = bounds
    }
    
    /// ...
    public mutating func random<RNG: RandomNumberGenerator>(_ rng: inout RNG) -> Double {
        return (bounds.upperBound - bounds.lowerBound) * rng.nextDouble() + bounds.lowerBound
    }
    
    /// ...
    public var bounds: Range<Double>
}

/// ...
extension Uniform: CustomStringConvertible {
    
    public var description: String {
        return "Uniform( [\(bounds.lowerBound), \(bounds.upperBound)) )"
    }
}


