//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//

import Foundation

typealias Gene = String
typealias Genome = String
typealias GenomeSlice = Substring
typealias GenomeIndex = String.Index

var A: Character { return "A" } // Activator -- Bool
var B: Character { return "B" } // Generic Bool
var D: Character { return "D" } // Generic Double
var H: Character { return "H" } // Hox gene
var I: Character { return "I" } // Generic Int
var L: Character { return "L" } // Layer
var N: Character { return "N" } // Neuron
var W: Character { return "w" } // Weight -- Double
var b: Character { return "b" } // bias as Double
var t: Character { return "t" } // threshold as Double

enum Utilities {
    static var filenameSerialNumber = 0
    
    static func clobbered(_ message: String) { print(message); fatalError(message) }

    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    static func makeFullPath(_ filename: URL) -> URL {
        let filename = String(format: "txt%04d.txt", filenameSerialNumber)
        let fullPath = Utilities.getDocumentsDirectory().appendingPathComponent(filename)
        
        filenameSerialNumber += 1
        return fullPath
    }
    
    static func generateGenome() -> Genome {
        // The map is so we can weight the gene types differently, so we
        // don't end up with one neuron per layer, or something silly like that.
        let geneSelector = [A : 5, L : 1, N : 3, W : 5, b : 4, t : 4]
        
        var workingGenome = Genome()
        var weightedGeneSelector: [Character] = {
            var t = [Character]()
            for (geneType, weight) in geneSelector {
                for _ in 0..<weight { t.append(geneType) }
            }
            return t
        }()
        
        for _ in 0..<100 {
            let geneSS = Int.random(in: 0..<weightedGeneSelector.count)
            let geneType = weightedGeneSelector[geneSS]
            
            switch geneType {
            case A: workingGenome += "A(\(Bool.random()))."
            case L: workingGenome += "L."
            case N: workingGenome += "N."
            case W: workingGenome += "W(\(Double.random(in: -100...100).sTruncate()))."
            case b: workingGenome += "b(\(Double.random(in: -100...100).sTruncate()))."
            case t: workingGenome += "t(\(Double.random(in: -100...100).sTruncate()))."
            default: fatalError()
            }
        }
        
        return workingGenome
    }


//    static func hurl(_ exception: DecodeError) throws { throw exception }
    
    static func load(filename: String) -> [Genome] {
        do {
            let fullPathURL = Utilities.getDocumentsDirectory().appendingPathComponent(filename)
            let jsonString = try String(contentsOf: fullPathURL)
            
            let strands = try JSONDecoder().decode([Genome].self, from: jsonString.data(using: .utf8)!)
            return strands
        } catch {
            print(error)
            fatalError()
        }
    }
    
    static func save(_ strands: [Genome], to filename: String) -> String {
        do {
            let json = try JSONEncoder().encode(strands)
            
            let fullPath = Utilities.getDocumentsDirectory().appendingPathComponent(filename)
            
            filenameSerialNumber += 1
            
            try json.write(to: fullPath)
            return fullPath.absoluteString
        } catch {
            // print(error)
            fatalError()
        }
    }
}

extension Double {
    func sTruncate() -> String {
        let t = Double(truncating: NSNumber(floatLiteral: self))
        return String(format: "%.5f", t)
    }

    func dTruncate() -> Double {
        return Double(sTruncate())!
    }
}

infix operator ~~=
infix operator ~~+
extension String {
    // With deepest gratitude to Paul Hudson
    // https://twitter.com/twostraws
    // https://www.hackingwithswift.com/articles/108/how-to-use-regular-expressions-in-swift
    //
    static func ~= (lhs: String, rhs: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: rhs) else { return false }
        let range = NSRange(location: 0, length: lhs.utf16.count)
        return regex.firstMatch(in: lhs, options: [], range: range) != nil
    }
    
    // With deepest gratitude to StackOverflow denizen Martn R
    // https://stackoverflow.com/users/1187415/martin-r
    // https://stackoverflow.com/a/27880748/1610473
    //
    static func ~~= (stringToSearch: String, patternToMatch: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: patternToMatch)
            let results = regex.matches(in: stringToSearch,
                                        range: NSRange(stringToSearch.startIndex..., in: stringToSearch))
            return results.map {
                String(stringToSearch[Range($0.range, in: stringToSearch)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}

// With deepest gratitude to StackOverflow dudes
// https://stackoverflow.com/users/1786016/arti
// https://stackoverflow.com/users/59541/nate-cook
// https://stackoverflow.com/questions/33290955/regex-capture-group-swift
extension String {
    func searchRegex (regex: String) -> Array<String> {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: NSRegularExpression.Options(rawValue: 0))
            let nsstr = self as NSString
            let all = NSRange(location: 0, length: nsstr.length)
            var hatches : Array<String> = Array<String>()
            regex.enumerateMatches(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: all)
            {(result : NSTextCheckingResult?, _, _) in
                
                let capturedRange = result!.range(at: 1)
                if !NSEqualRanges(capturedRange, NSMakeRange(NSNotFound, 0)) {
                    let theResult = nsstr.substring(with: result!.range(at: 1))
                    hatches.append(theResult)
                }
            }
            return hatches
        } catch {
            return Array<String>()
        }
    }
}

extension NSTextCheckingResult {
    func groups(testedString:String) -> [String] {
        var groups = [String]()
        for i in  0 ..< self.numberOfRanges
        {
            let group = String(testedString[Range(self.range(at: i), in: testedString)!])
            groups.append(group)
        }
        return groups
    }
}
