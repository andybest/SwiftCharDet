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

import XCTest
import Foundation
@testable import SwiftCharDet

class SwiftCharDetTests: XCTestCase {
    
    func testFilePath(forFile fileName: String) -> String {
        return FileManager.default.currentDirectoryPath + "/\(fileName)"
    }
    
    func testDetectUTF8() {
        var encoding: String.Encoding = .ascii
        
        do {
            encoding = try CharacterEncodingDetector.detectEncodingOfFile(testFilePath(forFile: "testFiles/utf8Sample.txt"))
        } catch {
            XCTFail("Should not throw an error")
        }
            
        XCTAssertEqual(encoding, String.Encoding.utf8)
    }
    
    func testDetectUTF16BigEndian() {
        var encoding: String.Encoding = .ascii
        
        do {
            encoding = try CharacterEncodingDetector.detectEncodingOfFile(testFilePath(forFile: "testFiles/utf16Sample_BE.txt"))
        } catch {
            XCTFail("Should not throw an error")
        }
        
        XCTAssertEqual(encoding, String.Encoding.utf16BigEndian)
    }
    
    func testDetectUTF16LittleEndian() {
        var encoding: String.Encoding = .ascii
        
        do {
            encoding = try CharacterEncodingDetector.detectEncodingOfFile(testFilePath(forFile: "testFiles/utf16Sample_LE.txt"))
        } catch {
            XCTFail("Should not throw an error")
        }
        
        XCTAssertEqual(encoding, String.Encoding.utf16LittleEndian)
    }
    
    func testDetectISO2022_JP() {
        var encoding: String.Encoding = .ascii
        
        do {
            encoding = try CharacterEncodingDetector.detectEncodingOfFile(testFilePath(forFile: "testFiles/iso2022-jpSample.txt"))
        } catch {
            XCTFail("Should not throw an error")
        }
        
        XCTAssertEqual(encoding, String.Encoding.iso2022JP)
    }
    
    func testDetectISOLatin1() {
        var encoding: String.Encoding = .ascii
        
        do {
            encoding = try CharacterEncodingDetector.detectEncodingOfFile(testFilePath(forFile: "testFiles/isoLatin1Sample.txt"))
        } catch {
            XCTFail("Should not throw an error")
        }
        
        XCTAssertEqual(encoding, String.Encoding.isoLatin1)
    }


    static var allTests: [(String, (SwiftCharDetTests) -> () -> Void)] = [
        ("testDetectUTF8", testDetectUTF8),
        ("testDetectUTF16BigEndian", testDetectUTF16BigEndian),
        ("testDetectUTF16LittleEndian", testDetectUTF16LittleEndian),
    ]
}
