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

struct CharacterEncodingDetector {
    static func confidencesForEncodingOfFile(_ path: String) throws -> [String.Encoding: Double] {
        let fileData = try Data(contentsOf: URL(fileURLWithPath: path))
        
        // Take a 2k sample of the file to run the detectors against
        let sample: Data
        if fileData.count > 2048 {
            sample = fileData[0..<2048]
        } else {
            sample = fileData
        }
        
        // Check ASCII first, since it's relatively straightforward
        let asciiConfidence = ASCIIEncodingDetector.encodingConfidence(forData: sample)
        let utf8Confidence = UTF8EncodingDetector.encodingConfidence(forData: sample)
        let utf16Confidence = UTF16EncodingDetector.encodingConfidence(forData: sample)
        let iso2022_jpConfidence = ISO2022JPEncodingDetector.encodingConfidence(forData: sample)
        let isoLatin1Confidence = ISOLatin1Detector.encodingConfidence(forData: sample)
        
        let confidences = [
            asciiConfidence.1: asciiConfidence.0,
            utf8Confidence.1: utf8Confidence.0,
            utf16Confidence.1: utf16Confidence.0,
            iso2022_jpConfidence.1: iso2022_jpConfidence.0,
            isoLatin1Confidence.1: isoLatin1Confidence.0
        ]
        
        return confidences
    }
    
    static func detectEncodingOfFile(_ path: String) throws -> String.Encoding {
        let confidences = try confidencesForEncodingOfFile(path)
        
        let sorted = confidences.sorted { i1, i2 in
            i1.value > i2.value
        }
        
        return sorted.first!.key
    }
}
