import Foundation



// MARK: - Game Category:
/// Specifies what type of operator to test for like .`add`, .`mult`
@available(iOS 13.0, *)
public enum MLMathMasterGameCategory {
    case add, subtract, multiply, divide, random
    
    static func random() -> MLMathMasterGameCategory {
        return [Self.add, Self.multiply, Self.subtract].randomElement()!
    }
    
    public func asString() -> String{
        switch  self {
        case .add:
            return "+"
        case .subtract:
            return  "-"
        case .multiply:
            return "*"
        default:
            return "random"
        }
    }
    
}


@available(iOS 13.0, *)
public enum MLMathMasterGameTimeAttackTime {
    case none
    case test10Sek
    case oneMin
    case twoMin
    case fiveMin
    case tenMin
    
    func asSeconds() -> Double {
        switch self {
        case .none:
            return 0
        case .test10Sek:
            return 10
        case .oneMin:
            return 60
        case .twoMin:
            return 120
        case .fiveMin:
            return 300
        case .tenMin:
            return 600
        }
    }
}




// MARK: - GameType
/// Game Type: What type of game(test) we are doing, like .sequence (like tables), .random
@available(iOS 13.0, *)
public enum MLMathMasterGameType: Equatable{
    case sequence
    case random(_ max: Int = 10)
    case timeAttack(_ max: Int = 10)
    
    func max() -> Double? {
        switch self {
        case .random(let num):
            return Double(num)
        case .timeAttack(let num):
            return Double(num)
        default: return nil
        }
    }
    
    var isTimeAttack: Bool {
        if case .timeAttack = self {
            return true
        }
        return false
    }
}






// MARK: - GameData
/// Game Data: Holds information about one game, like `category`, `type`, `base` and so on
@available(iOS 13.0, *)
public struct MLMathMasterGameData {
    var category: MLMathMasterGameCategory
    var type: MLMathMasterGameType
    var base: [Int] = []
    var timeAttackTime: MLMathMasterGameTimeAttackTime = .none
    var groupSize: Int
    var noOfQuestions: Int
}






// MARK: - GameState
@available(iOS 13.0, *)
public enum MLMathMasterGameState {
    case none, initialized, started, timeAttackStarted, stopped
}






// MARK: - GameSettings
/// Game settings: settings for the MLMathMaster game
@available(iOS 13.0, *)
public struct MLMathMasterGameSettings {
    var noOfQuestions: Int = 10
}






// MARK: - Question
/// Question struct: Holds the information about one question
/// NOTE!!! category will never be random.. if the game.category is random.. the question category will be one of the valid (add, sub, mult) categories
@available(iOS 13.0, *)
public class MLMathMasterQuestion: Identifiable, Equatable {
    public static func == (lhs: MLMathMasterQuestion, rhs: MLMathMasterQuestion) -> Bool {
        lhs.id == rhs.id
    }
    
    public var id = UUID()
    public var value1: Int
    public var value2: Int
    public var category: MLMathMasterGameCategory
    fileprivate(set) var result: MLMathMasterQuestionResult?
    fileprivate(set) var _active: Bool = false {
        willSet {
            if newValue == true {
                startTime = .now()
                stopTime = nil
            } else {
                stopTime = .now()
            }
        }
    }
    fileprivate(set) var evaluated: Bool = false {
        willSet {
            if newValue == true {
                stopTime = .now()
            }
        }
    }
    
    public var active: Bool {
        get {
            return self._active
        }
    }
    
    public var startTime: DispatchTime?
    public var stopTime: DispatchTime?
    
    public var totalTime: Double {
        guard startTime != nil, stopTime != nil else {
            return -1
        }
        return Double(stopTime!.rawValue - startTime!.rawValue) / Double(1000000000)
    }
    
    
    init(value1: Int, value2: Int, category: MLMathMasterGameCategory) {
        self.value1 = value1
        self.value2 = value2
        self.category = category
    }
    
    public func asString() -> String {
        return "\(value1) \(category.asString()) \(value2)"
    }
}





// MARK: - QuestionResult
/// Result struct containing information about a question
public struct MLMathMasterQuestionResult {
    var answer: Int
    var expectedAnswer: Int
    var success: Bool {
        answer == expectedAnswer
    }
}


// MARK: - Error
enum MLMathMasterEngineError: Error {
    case activateQuestionWhenPreviousQuestionIsNotEvaluated
    case evaluateQuestionBeforeItsActivated
    case getNextQuestionWhenPreviousQuestionIsNotFinished
    case notAllowedInTimeAttack
}

extension MLMathMasterEngineError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .activateQuestionWhenPreviousQuestionIsNotEvaluated:
            return NSLocalizedString(
                "Previous question must be evaluated before you can activate a new quest", comment: "")
        case .evaluateQuestionBeforeItsActivated:
            return NSLocalizedString(
                "You can't evaluate a Question before it has been activated", comment: "")
        case .getNextQuestionWhenPreviousQuestionIsNotFinished:
            return NSLocalizedString(
                "You cant fetch another question before the last question is evaluated", comment: "")
        case .notAllowedInTimeAttack:
            return NSLocalizedString(
                "This is not allowed in a TimeAttackGame", comment: "")
        }
    }
}

// MARK: -  Notifications
enum MLMathMasterEngineNotifications: String {
    case timeAttackStart = "TimeAttackStart"
    case timeAttackEnd = "TimeAttackEnd"
}



// MARK: - QuestionManagerDelegate
public protocol MLMathMasterGameQuestionManagerDelegate {
    func lastQuestionEvaluated()
    func firstQuestionActivated()
}




// MARK: - QuestionManager
@available(iOS 13.0, *)
/// Manages all questions in the game.
///  it will generate questions up to `noOfQuestions` in a rate specified by `groupSize`
///  if groupSize = -1 then all questions will be generated at once and stored into currentQuestions
///  if groupSize != -1 then the amount of questions specified by `groupSize` will be generated.. and when
///  the last question is evaluated of the currentQuestions a new batch is fetched.
///
///  Activate question, Evaluate question and so on refere to the currentQuestion
///
public class MLMathMasterGameQuestionManager {
    // MARK: - Private properties
    
    
    // MARK: - Public properties
    public var gameData: MLMathMasterGameData
    public var currentQuestions: [MLMathMasterQuestion] = []
    public var currentQuestion: MLMathMasterQuestion?
    public var answeredQuestions: [MLMathMasterQuestion] = []
    public var noOfRightAnswers: Int {
        return answeredQuestions.reduce(0) { (result, question) -> Int in
            guard let qResult = question.result, qResult.success else { return result}
            
            return result + 1
        }
    }
    
    public var unansweredQuestions: Int {
        return gameData.type.isTimeAttack
            ? -1
            : gameData.noOfQuestions - answeredQuestions.count
    }
    
    public var delegate: MLMathMasterGameQuestionManagerDelegate?
    
    // MARK: - life cycle
    public init (
        gameData: MLMathMasterGameData
    ) {
        self.gameData = gameData
    }
    
    
    // MARK: - Private Methods
    private func generateNewQuestion(index: Int?) -> MLMathMasterQuestion {
        
        let i = index ?? self.answeredQuestions.count
        let questionCategory = self.gameData.category != .random ? self.gameData.category : MLMathMasterGameCategory.random()
        
        return MLMathMasterQuestion(
            value1: getValue1(),
            value2: getValue2(index: i),
            category: questionCategory)
    }
    
    /// Generate a value for `value1` based on the `base` value.
    /// If the `base` value is a single value we just return that value.. otherwise we randomize between the values in the `base` array
    /// - Returns: Integer value
    private func getValue1() -> Int {
        if gameData.base != [] {
            if gameData.base.count == 1 {
                return gameData.base[0]
            } else {
                return gameData.base[Int.random(in: 0...gameData.base.count-1)]
            }
        } else {
            print("No Base value \(#function)")
            return 0
        }
    }
    
    
    
    /// Generate a value for `value2` based on the `type` value in `gameData`
    /// If it is a `.sequence` we just return the `index` supplied to the method otherwise (not sequence) we randomize the number
    /// - Parameter index: value that can be used to create a sequence if the gameType is .sequence
    /// - Returns: The value
    private func getValue2(index: Int) -> Int {
        if  gameData.base != [] {
            switch gameData.type {
            case .sequence:
                return index - 1
            case .random(let max):
                return Int.random(in: 1...max)
            case .timeAttack(let max):
                return Int.random(in: 1...max)
            }
        } else {
            print("No base value \(#function)")
            return 0
        }
    }
    
    private func newBatchRequired() -> Bool {
        return currentQuestions == [] || lastQuestionInBatchEvaluated()
    }
        
    private func lastQuestionInBatchEvaluated() -> Bool {
        guard currentQuestions.count > 0 else { return false }
        
        return currentQuestions.last!.result != nil
    }
    
    private func lastQuestionEvaluated() -> Bool {
        if gameData.noOfQuestions == -1 {
            return false
        }
        
        return gameData.noOfQuestions == answeredQuestions.count
    }
    
    private func isFirstQuestion() -> Bool {
        return answeredQuestions.count == 0
    }
    
    
    private func createNewQuestions() {
        currentQuestions = []
        var count: Int
        
        let groupSize = gameData.groupSize == -1 ? gameData.noOfQuestions : gameData.groupSize
        
        // if timeAttackGame.. just return groupSize
        if gameData.noOfQuestions == -1 {
            count = groupSize
        } else {
            count = min(groupSize, gameData.noOfQuestions - answeredQuestions.count)
        }
        
        
        
        guard count > 0 else { return }
        
        let offset = self.answeredQuestions.count
        
        /// Need to think about how to specify count.. when noOfQuestions = -1 we want to feed it for ever
        for i in (1...count) {
            currentQuestions.append(generateNewQuestion(index: i + offset))
        }
    }
    
    
    /// Return next question from currentQuestions. if there is no currently active questions we return the first
    /// - Returns: <#description#>
    private func getNextQuestion() -> MLMathMasterQuestion {
        var question: MLMathMasterQuestion?
        
        for (index, element) in currentQuestions.enumerated() {
            if element.active && index < currentQuestions.count - 1 {
                question = currentQuestions[index + 1]
                break
            }
        }
        return question ?? currentQuestions[0]
    }
    
    
    /// Evaluates the value by combining the two values in the question with the right operator specified by the gameData.category type
    /// - Parameter question: <#question description#>
    /// - Returns: <#description#>
    private func getResultOf(question: MLMathMasterQuestion) -> Int {
        switch question.category {
        case .add:
            return question.value1 + question.value2
        case .subtract:
            return question.value1 - question.value2
        case .multiply:
            return question.value1 * question.value2
        default:
            return -1
        }
    }
    
    /// Adds the result to the question.. the reason for this is that its value typed and I could not get the value back in a nice way..
    /// - Parameters:
    ///   - question: the question that will get a result struct
    ///   - result: the result struct
    private func addResultToQuestion(result: MLMathMasterQuestionResult) {
        currentQuestion?.result = result
    }
    
    
    private func addCurrentQuestionToAnsweredQuestions() {
        guard let question = currentQuestion else { return }
        answeredQuestions.append(question)
    }
    
    
    
    
    
    
    
    
    
    // MARK: - Public Methods
    
    /// Get the next question to be activated. Inactivate previous activated question
    /// - Returns: optional Question
    public func activateNextQuestion() throws {
        
        guard !lastQuestionEvaluated() else {
            currentQuestion = nil
            return
        }
        
        // check if current question is not evaluated yet.. that is an error
        if currentQuestion  != nil
            && currentQuestion?.result == nil {
               throw MLMathMasterEngineError.activateQuestionWhenPreviousQuestionIsNotEvaluated
           }
        
        
        
        if newBatchRequired() {
            createNewQuestions()
        }
        
        
        let nextQuestion = getNextQuestion()
        currentQuestion?._active = false
        currentQuestion = nextQuestion
        currentQuestion?._active = true

        if isFirstQuestion() {
            delegate?.firstQuestionActivated()
        }
    }
    
    /// Evaluates a MLMathMasterQuestion by calling `getResultOf` that returns the answer
    /// It then creates a result-struct (MLMathMasterQuestionResult), attaches the result to the question,
    /// removes the question from `unansweredQuestions` and returns the result
    /// - Parameters:
    ///   - question: the question to evaluate
    ///   - answer: the players answer
    /// - Returns: A MLMathMasterQuestionResult containing the result
    public func evaluateQuestion(answer: Int) throws -> MLMathMasterQuestionResult? {
        guard currentQuestion?._active == true else {
            throw MLMathMasterEngineError.evaluateQuestionBeforeItsActivated
        }
        
        let correctAnswer = getResultOf(question: currentQuestion!)
        let result = MLMathMasterQuestionResult(
            answer: answer,
            expectedAnswer: correctAnswer)
        
        currentQuestion?.evaluated = true
        addResultToQuestion(result: result)
        addCurrentQuestionToAnsweredQuestions()

        if lastQuestionEvaluated() {
            answeredQuestions.last!._active = false
            currentQuestion?._active = false
            delegate?.lastQuestionEvaluated()
        }

        

        return result
    }
    
    
    
}













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
