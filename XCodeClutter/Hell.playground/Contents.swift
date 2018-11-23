import Foundation
extension String {
    typealias CaptureElement = Array<String>
    typealias CaptureGroup = Array<CaptureElement>
    func searchRegex (regex: String) -> CaptureGroup {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: NSRegularExpression.Options(rawValue: 0))
            let nsstr = self as NSString
            let all = NSRange(location: 0, length: nsstr.length)
            var hatches = CaptureGroup()
            regex.enumerateMatches(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: all)
            {(result : NSTextCheckingResult?, _, _) in
                
                if let r = result?.groups(testedString: self) {
                    hatches.append(r)
                }
                //                print("rob", result?.groups(testedString: self))
                //                let capturedRange = result!.range(at: 1)
                //                if !NSEqualRanges(capturedRange, NSMakeRange(NSNotFound, 0)) {
                //                    let theResult = nsstr.substring(with: result!.range(at: 1))
                //                    hatches.append(theResult)
                //                }
            }
            return hatches
        } catch {
            return CaptureGroup()
        }
    }
}

extension NSTextCheckingResult {
    func groups(testedString:String) -> [String] {
        var groups = [String]()
        for i in  0 ..< self.numberOfRanges {
            let thisRange = self.range(at: i)
            guard let r = Range(thisRange, in: testedString) else { return groups }
            
            let group = String(testedString[r])
            groups.append(group)
        }
        return groups
    }
}

typealias Genome = String
func getRawComponentSets(for genome: Genome) -> [[String]] {

    let reTokenPass = "[LN]_|([ABHLNTW])\\(([^\\(]*)\\)_"

    var componentSets = [[String]]()
    let tokenPassResults = genome.searchRegex(regex: reTokenPass)

    for tokenPassComponent in tokenPassResults {
        componentSets.append(getRawComponentSet(for: tokenPassComponent))
    }

    return componentSets
}

func getRawComponentSet(for gene: [String], isFullGene: Bool = true) -> [String] {
    let geneSS = (isFullGene && gene.count > 1) ? 2 : 0
    
    print(gene, geneSS)
    let geneMatch = gene[geneSS]
    var workingSet = [String]()
    
    let reValuePass = "b\\[(-?\\d*\\.?\\d*)\\]v\\[(-?\\d*\\.?\\d*)\\]"

    // This is for markers that don't carry values,
    // like L_ and N_. Drop the _ and keep the gene
    // type only.
    if isFullGene && gene.count == 1 {
        let t = String(geneMatch.dropLast())
        workingSet.append(t);
        return workingSet
    }
    
    let valuePassResults = geneMatch.searchRegex(regex: reValuePass)
    
    // This is for activators. No special parsing necessary
    if isFullGene && valuePassResults.isEmpty {
        let t = gene.dropFirst()
        workingSet.append(contentsOf: t)
        return workingSet
    }
    
    // ValueDoublet
    if isFullGene { workingSet.append(gene[1]) }
    else { workingSet.append("X") } // Not used; just a placeholder
    
    workingSet.append(valuePassResults[0][1])
    workingSet.append(valuePassResults[0][2])
    return workingSet
}

func getRawComponentSet(for gene: Substring) -> [String] {
    return getRawComponentSet(for: [String(gene)], isFullGene: false)
}

let genome = "L_N_"
print("Final", getRawComponentSets(for: "B(b[-42.0]v[-82.7])_"))
print("semiFinal", getRawComponentSet(for: "b[-42.0]v[-82.7]"[...]))
print("And another thing", getRawComponentSets(for: genome))
