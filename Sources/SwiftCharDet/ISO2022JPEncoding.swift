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

struct ISO2022JPEncodingDetector: StringEncodingDetector {
    private enum CurrentMode {
        case ascii
        case jisX0201_1976
        case jisX0208_1978
        case jisX0208_1983
    }
    
    static func encodingConfidence(forData sampleData: Data) -> (Double, String.Encoding) {
        // ISO 2022-JP uses escape sequences to switch between different character sets.
        
        var charIdx = 0
        var confidence = 0
        
        // Always starts in ascii
        var currentMode: CurrentMode = .ascii
        
        while charIdx < sampleData.count {
            // Is this an escape sequence?
            if sampleData[charIdx] == 0x1B {
                if sampleData.count - charIdx < 3 {
                    // Invalid escape sequence- there aren't enough bytes left.
                    charIdx += 1
                    continue
                }
                
                // ESC (
                if sampleData[charIdx + 1] == 0x28 {
                    // ESC ( B
                    if sampleData[charIdx + 2] == 0x42 {
                        currentMode = .ascii
                        charIdx += 3
                        confidence += 3
                        continue
                    }
                    
                    // ESC ( J
                    if sampleData[charIdx + 2] == 0x4A {
                        currentMode = .jisX0201_1976
                        charIdx += 3
                        confidence += 3
                        continue
                    }
                }
                
                // ESC $
                if sampleData[charIdx + 1] == 0x24 {
                    // ESC $ @
                    if sampleData[charIdx + 2] == 0x40 {
                        currentMode = .jisX0208_1978
                        charIdx += 3
                        confidence += 3
                        continue
                    }
                    
                    // ESC $ B
                    if sampleData[charIdx + 2] == 0x42 {
                        currentMode = .jisX0208_1983
                        charIdx += 3
                        confidence += 3
                        continue
                    }
                }
                
                // Invalid escape sequence
                charIdx += 1
                continue
            }
            
            switch currentMode {
            case .ascii:
                if sampleData[charIdx] < 0x80 {
                    confidence += 1
                }
                charIdx += 1
                continue
                
            case .jisX0201_1976:
                // One byte per character
                let char = sampleData[charIdx]
                
                // Check that the character is in range
                if (char > 0x1F && char < 0x7F) || (char > 0xA0 && char < 0xE0) {
                    confidence += 1
                }
                charIdx += 1
                continue
                
            case .jisX0208_1978:
                // 2 bytes per character
                confidence += 2
                charIdx += 2
                continue
                
            case .jisX0208_1983:
                // 2 bytes per character
                confidence += 2
                charIdx += 2
                continue
            }
            
        }
        
        return (Double(confidence) / Double(sampleData.count), .iso2022JP)
    }
}
