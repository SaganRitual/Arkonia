import Foundation

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

let a = "hello\"there\""
print(a)

let genomeRx = ""
let genome = "L.N.A(true).W(1).b(1).b(37).t(12).t(1107).N.A(true).W(2.75).A(false).W(3).N.A(true).W(4).A(false).W(5).A(true).W(6).A(true).b(2).t(100)."

let regex = "L\\.|N\\.|[AB]\\((true|false)\\)\\.|[bDtW]\\((\\d*\\.?\\d*)\\)\\.|I\\((\\d+)\\)"
print(regex)

let segex = "(?:L\\.)|(?:N\\.)|(?:[AB]\\((true|false)\\)\\.)|(?:[bDtW]\\((\\d*\\.?\\d*)\\)\\.)|(?:I\\((\\d+)\\)\\.)"
print()
print(segex)
print()

let matches = genome.searchRegex(regex: segex)
print(matches)
