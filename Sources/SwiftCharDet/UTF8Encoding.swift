/*
 
 MIT License
 
 Copyright (c) 2017 Andy Best
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
 */

import Foundation

struct UTF8EncodingDetector {
    
    static func encodingConfidence(forData sampleData: Data) -> (Double, String.Encoding) {
        /*
         * Information for valid UTF-8 sequences can be found at the following
         * Wikipedia page: https://en.wikipedia.org/wiki/UTF-8
         */
        
        var byteIdx = 0
        var confidence = 0
        
        // Check byte sequences
        while byteIdx < sampleData.count {
            // Check if the MSB is set. If it is, then it's an ASCII byte
            if sampleData[byteIdx] & 0x80 == 0 {
                byteIdx += 1
                confidence += 1
                continue
            }
            
            // Check sequence length. The first byte in the sequence will
            // indicate how many bytes should be in the sequence
            let seqLength: Int
            
            if sampleData[byteIdx] & 0b11100000 == 0b11000000 {
                seqLength = 2
            } else if sampleData[byteIdx] & 0b11100000 == 0b11100000 {
                seqLength = 3
            } else if sampleData[byteIdx] & 0b11110000 == 0b11110000 {
                seqLength = 4
            } else {
                // Invalid UTF-8 byte sequence!
                byteIdx += 1
                continue
            }
            
            for seqIdx in 1..<seqLength {
                // Each additional byte should be of the format 10xxxxxx
                if sampleData[byteIdx + seqIdx] & 0b11000000 != 0b10000000 {
                    // Invalid UTF-8 byte sequence!
                    byteIdx += 1
                    continue
                }
            }
            
            byteIdx += seqLength
            confidence += seqLength
        }
        
        return (Double(confidence) / Double(sampleData.count), .utf8)
    }
}
