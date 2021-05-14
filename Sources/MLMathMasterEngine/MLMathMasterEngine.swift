
import Foundation


// MARK: - Engine
/// The MLMathMaster game engine.
/// The controller of the game.
/// You initialize a new game by calling `func newGame()` and specify what type and category and so on you want to test
@available(iOS 13.0, *)
public class MLMathMasterEngine: ObservableObject{
    
    // MARK: - private properties
    private var timer: Timer?

    // MARK: - public properties
    //    @Published public var questions: [MLMathMasterQuestion] = []
    @Published public var qm: MLMathMasterGameQuestionManager?
    @Published public var gameData: MLMathMasterGameData?
    @Published public var settings: MLMathMasterGameSettings
    @Published public var gameState: MLMathMasterGameState = .none {
        didSet {
            switch gameState {
            case .started:
                startTime = .now()
            case .stopped:
                stopTime = .now()
            case .timeAttackStarted:
                currentTime = 0
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] timer in
                    guard let self = self else { return }
                    
                    self.currentTime += 1
                    
                    if self.currentTime >
                        self.gameData!.timeAttackTime.asSeconds() {
                        
                        self.gameState = .stopped
                        
                        NotificationCenter.default.post(name: NSNotification.Name(MLMathMasterEngineNotifications.timeAttackEnd.rawValue), object: nil)
                        
                        timer.invalidate()
                    }
                })
            default:
                return
            }
        }
    }
        
    public var startTime: DispatchTime?
    public var stopTime: DispatchTime?
    @Published public var currentTime: Double = 0 // seconds
    
    public var totalTime: Double {
        guard startTime != nil, stopTime != nil else {
            return -1
        }
        return Double(stopTime!.rawValue - startTime!.rawValue) / Double(1000000000)
    }
    
    public init(settings: MLMathMasterGameSettings? = nil) {
        self.settings = settings ?? MLMathMasterGameSettings()
    }
    
    
    
    
    
    // MARK: - Private methods
    
    
    // MARK: - Public methods
    
    
    /// Start new game.
    /// Creates a new GameData (MLMathMasterGameData) struct based.
    /// Generates new questions base on the `type`, `category` and `base` values
    /// If `noOfQuestions` is nil then the value from `settings.noOfQuestions` will be used
    /// - Parameters:
    ///   - category: MLMathMasterGameCategory. (the type of operation that is tested.. like .add)
    ///   - type: MLMathMasterGameType: Wheter it is .sequense (like tables) or .random (for challange)
    ///   - base: [Int], array of what numbers are the base for testing.. like [2] .. testing variants based on to like (2+3 if .add) (2*6 if .mult) and so on
    ///   - noOfQuestions: Optional number of questions.. overrides the `settings.noOfQuestions` to produce
    public func newTimeAttackGame(
        category: MLMathMasterGameCategory,
        max: Int,
        base: [Int],
        timeAttackTime: MLMathMasterGameTimeAttackTime) {
        gameData = MLMathMasterGameData(category: category, type: .timeAttack(max), base: base, timeAttackTime: timeAttackTime, groupSize: 1, noOfQuestions: -1)
        
        qm = MLMathMasterGameQuestionManager(gameData: gameData!)
        qm?.delegate = self
        gameState = .initialized
    }
    
    public func newGame(
        category: MLMathMasterGameCategory,
        type: MLMathMasterGameType,
        base: [Int],
        noOfQuestions: Int? = nil,
        groupSize: Int = 1) {
        
        gameData = MLMathMasterGameData(category: category, type: type, base: base, groupSize: groupSize, noOfQuestions: noOfQuestions ?? settings.noOfQuestions)
        qm = MLMathMasterGameQuestionManager(gameData: gameData!)
        
        qm?.delegate = self
        
        gameState = .initialized
    }
     
    
    public func startGame() {
        guard let gameData = gameData else { return }
        
        if gameData.type.isTimeAttack {
            self.gameState = .timeAttackStarted
        } else {
            self.gameState = .started
        }
    }
    
    public func stopGame() {
        self.gameState = .stopped
    }
}


@available(iOS 13.0, *)
extension MLMathMasterEngine: MLMathMasterGameQuestionManagerDelegate {
    public func lastQuestionEvaluated() {
        self.stopGame()
    }
    
    public func firstQuestionActivated() {
        self.startGame()
    }
    
    
}
