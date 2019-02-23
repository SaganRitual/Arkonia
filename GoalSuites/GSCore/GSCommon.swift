import Foundation

enum GSComparison: String { case ANY, BE, BT, EQ }

protocol GSFactoryProtocol: class, CustomStringConvertible {
    var genomeWorkspace: String { get set }

    func getAboriginal() -> GSSubjectProtocol
    func makeArkon(genome: Genome, mutate: Bool) -> GSSubjectProtocol?
    func mutate(from: Genome)
}

protocol GSGoalSuiteProtocol: class, CustomStringConvertible {
    var factory: GSFactoryProtocol { get }
    var tester: GSTesterProtocol { get }

    var selectionControls: KSelectionControls { get set }
}

protocol GSSubjectProtocol: class, CustomStringConvertible {
    var fishNumber: Int { get }
    var fitnessScore: Double { get set }
    var genome: Genome { get set }
    var hashedAlready: SetOnce<Int> { get set }
    var spawnCount: Int { get set }
    var suite: GSGoalSuiteProtocol? { get set }

    init()
    func postInit(suite: GSGoalSuiteProtocol)
}

protocol LightLabelProtocol {
    var lightLabel: String { get }
}
