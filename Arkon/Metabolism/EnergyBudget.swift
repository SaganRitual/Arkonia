// EnergyBudget.swift is auto-generated. Open the spreadsheet with Numbers
// and export it to csv at the place pointed to in energy-budget.sh -- the script
// that strips out the commas and quotes
import Foundation
struct EnergyBudget {
struct Accessory {}
struct Fat {}
struct Lungs {}
struct Manna {}
struct Ready {}
struct Spawn {}
struct Stomach {}
struct VitaminStore {}
struct World {}
}
extension EnergyBudget.Accessory {
static let capacityVolts:CGFloat=1.000000
static let densityKgPerVcap:CGFloat=1
static let maintCostJoulesPerVcap:CGFloat=1
static let mfgCostJoulesPerVcap:CGFloat=1
static let useCostJoulesPerVCap:CGFloat=1.000000
static let useCostKgVitamin:CGFloat=0.100000
static let outputBasisVolts:CGFloat=1.000000
}
extension EnergyBudget.Fat {
static let capacityKg:CGFloat=3.000000
static let densityKgPerJoule:CGFloat=0.01
static let overflowFullness:CGFloat=0.75
static let maintCostJoulesPerKgCap:CGFloat=0.5
static let mfgCostJoulesPerKgCap:CGFloat=1
}
extension EnergyBudget.Lungs {
static let capacityCCs:CGFloat=25.000000
static let combustionCCsPerJoule:CGFloat=0.1
static let densityKgPerCC:CGFloat=1.309E-06// Says Wolfram Alpha
static let initialValue:CGFloat=25.000000
static let maintCostJoulesPerCCcap:CGFloat=0.5
static let mfgCostJoulesPerCCcap:CGFloat=1
}
extension EnergyBudget.Manna {
static let boneKg:CGFloat=1
static let hamKg:CGFloat=1
static let hamDensityKgPerJoule:CGFloat=0.1
static let leatherKg:CGFloat=1
static let oxygenCCs:CGFloat=20
static let poisonKg:CGFloat=1
}
extension EnergyBudget.Ready {
static let capacityJoules:CGFloat=30.000000
static let densityKgPerJoule:CGFloat=0.1
static let initialValue:CGFloat=30.000000
static let maintCostJoulesPerJcap:CGFloat=0.5
static let mfgCostJoulesPerJcap:CGFloat=1
static let overflowFullness:CGFloat=0.75
static let underflowFullness:CGFloat=0.25
}
extension EnergyBudget.Spawn {
static let capacityKg:CGFloat=6
static let densityKgPerJoule:CGFloat=0.5
static let initialValue:CGFloat=0
static let maintCostJoulesPerKgcap:CGFloat=0.5
static let mfgCostJoulesPerKgcap:CGFloat=1
}
extension EnergyBudget.Stomach {
static let capacityKg:CGFloat=7.1875
static let densityKgPerJoule:CGFloat=0.01
static let initialValue:CGFloat=0
static let maintCostJoulesPerKgcap:CGFloat=0.5
static let mfgCostJoulesPerKgcap:CGFloat=1
}
extension EnergyBudget.VitaminStore {
static let capacityKg:CGFloat=1.000000
static let densityKgPerJoule:CGFloat=0
static let maintCostJoulesPerKgcap:CGFloat=1
static let mfgCostJoulesPerKgcap:CGFloat=1
}
extension EnergyBudget.World {
static let pixPerMeter:CGFloat=100
static let standardSpeedPixPerSec:CGFloat=300
}
