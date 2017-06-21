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

struct UTF16EncodingDetector {
    
    static func encodingConfidence(forData sampleData: Data) -> (Double, String.Encoding) {
        var byteIdx = 0
        let byteOrdering: Int32
        var confidence = 0
        var nullBytes = 0
        
        // Look for a BOM at the beginning of the data
        if sampleData[0] == 0xFE && sampleData[1] == 0xFF {
            // Big-endian
            byteOrdering = BIG_ENDIAN
            byteIdx += 2
        } else if sampleData[0] == 0xFF && sampleData[1] == 0xFE {
            // Little-endian
            byteOrdering = LITTLE_ENDIAN
            byteIdx += 2
        } else {
            // There is no BOM, so just assume little endian.
            byteOrdering = LITTLE_ENDIAN
        }
        
        while byteIdx < sampleData.count {
            // Convert endianness
            var codeUnit1: UInt16 = (UInt16(sampleData[byteIdx + 1]) << 8) | UInt16(sampleData[byteIdx])
            if byteOrdering == BIG_ENDIAN {
                codeUnit1 = codeUnit1.bigEndian
            } else {
                codeUnit1 = codeUnit1.littleEndian
            }
            
            if codeUnit1 & 0xFF00 == 0 {
                nullBytes += 1
            }
            
            // Check if the sequence is in the Basic Multilingual Plane
            // 0x0000 > 0xD7FF || 0xE000 > 0xFFFF
            if codeUnit1 < 0xD800 || codeUnit1 > 0xDFFF {
                confidence += 2
                byteIdx += 2
                continue
            }
            
            // Check if it is a surrogate pair
            var codeUnit2: UInt16 = (UInt16(sampleData[byteIdx + 3]) << 8) | UInt16(sampleData[byteIdx + 2])
            if byteOrdering == BIG_ENDIAN {
                codeUnit2 = codeUnit2.bigEndian
            } else {
                codeUnit2 = codeUnit2.littleEndian
            }
            
            // The second code unit should be in the range 0xDC00 > 0xDFFF
            if codeUnit2 > 0xDBFF && codeUnit2 < 0xE000 {
                confidence += 4
                byteIdx += 4
            }
            
            // Didn't detect a valid UTF-16 sequence
            byteIdx += 4
        }
        
        var totalConfidence = Double(confidence) / Double(sampleData.count)
        
        // If there no null bytes, lower confidence, as this could be UTF-8
        if nullBytes == 0 {
            totalConfidence *= 0.75
        }
        
        return (totalConfidence, byteOrdering == LITTLE_ENDIAN ? .utf16LittleEndian : .utf16BigEndian)
    }
}
