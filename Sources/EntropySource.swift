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
// EntropySource.swift
// 06/23/2016
// -----------------------------------------------------------------------------

import Foundation

/// ...
public protocol EntropySource {
    
    /// ...
    init()

    /// ...
    func randomBytes() -> UInt32
    
    /// ...
    func randomBytes() -> UInt64
    
    /// ...
    func randomBytes(in buffer: UnsafeMutablePointer<Void>, count: Int)
}

/// ...
public struct Arc4Random: EntropySource {
    
    /// ...
    public init() {}
    
    /// ...
    public func randomBytes() -> UInt32 {
        return arc4random_uniform(UINT32_MAX)
    }
    
    /// ...
    public func randomBytes() -> UInt64 {
        let output: (UInt32, UInt32) = (randomBytes(), randomBytes())
        return unsafeBitCast(output, to:UInt64.self)
    }
    
    /// ...
    public func randomBytes(in buffer: UnsafeMutablePointer<Void>, count: Int) {
        arc4random_buf(buffer, count)
    }
}

/// ...
public final class DevRandom: EntropySource {

    /// ...
    public init() {
        self.handle = FileHandle(forReadingAtPath:"/dev/urandom").unsafelyUnwrapped
    }

    deinit {
        handle.closeFile()
    }
    
    /// ...
    public func randomBytes() -> UInt32 {
        var output: UInt32 = 0
        read(handle.fileDescriptor, &output, sizeof(UInt32))
        return output
    }
    
    /// ...
    public func randomBytes() -> UInt64 {
        var output: UInt64 = 0
        read(handle.fileDescriptor, &output, sizeof(UInt64))
        return output
    }
    
    /// ...
    public func randomBytes(in buffer: UnsafeMutablePointer<Void>, count: Int) {
        read(handle.fileDescriptor, buffer, count)
    }
    
    private let handle: FileHandle
}
