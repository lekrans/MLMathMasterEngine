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
    fileprivate(set) var active: Bool = false {
        willSet {
            if newValue == true {
                startTime = .now()
                stopTime = nil
            } else {
                stopTime = .now()
            }
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

enum MLMathMasterEngineNotifications: String {
    case timeAttackStart = "TimeAttackStart"
    case timeAttackEnd = "TimeAttackEnd"
}

// MARK: - Engine
/// The MLMathMaster game engine.
/// The controller of the game.
/// You initialize a new game by calling `func newGame()` and specify what type and category and so on you want to test
@available(iOS 13.0, *)
public class MLMathMasterEngine: ObservableObject {
    
    // MARK: - private properties
    private var timer: Timer?
    private var noOfFetchedQuestions: Int = 0
    private var currentQuestion: MLMathMasterQuestion? {
        willSet {
            if currentQuestion != nil {
                currentQuestion!.active = false
                
            }
            newValue?.active = false
        }
    }
    
    // MARK: - public properties
    @Published var questions: [MLMathMasterQuestion] = []
    
    var gameData: MLMathMasterGameData?
    var settings: MLMathMasterGameSettings
    var unansweredQuestions: [MLMathMasterQuestion] = []
    var gameState: MLMathMasterGameState = .none {
        didSet {
            switch gameState {
            case .started:
                startTime = .now()
            case .stopped:
                stopTime = .now()
            case .timeAttackStarted:
                timer = Timer.scheduledTimer(withTimeInterval: self.gameData!.timeAttackTime.asSeconds(), repeats: false, block: { (timer) in
                    self.gameState = .stopped
                    NotificationCenter.default.post(name: NSNotification.Name(MLMathMasterEngineNotifications.timeAttackEnd.rawValue), object: nil)
                })
            default:
                return
            }
        }
    }

    // MARK: - Computed properties
    var answeredQuestions: Int {
        questions.count - unansweredQuestions.count
    }
    var noOfRightAnswers: Int {
        var count = 0
        questions.forEach { (question) in
            if let result = question.result {
                if result.success == true {
                    count += 1
                }
            }
        }
        return count
    }
    
    public var startTime: DispatchTime?
    public var stopTime: DispatchTime?
    public var currentTime: Int = 0// seconds
    
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
    
    
    /// Reset and regenerates new questions based on the `count` value. These questions are stored in the `self.questions` array
    /// - Parameter count: No of questions to produce
    private func generateNewQuestions(count: Int) {

        questions = []
        for i in 1...count {
            questions.append(generateNewQuestion(index: i))
        }
        /// value semantic so this is a full copy
        self.unansweredQuestions = questions
    }
    
    
    /// Generate one question
    /// - Parameter index: optional value for creating sequences GenerateNewQuestions use this parameter to generate a sequence of values if the type is .sequence
    /// - Returns: A MLMathMasterQuestion
    private func generateNewQuestion(index: Int?) -> MLMathMasterQuestion {
        
        guard let gameData = self.gameData else {
            fatalError("No GameData when generating questions")
        }
        
        let i = index ?? questions.count
        let category = gameData.category != .random ? gameData.category : MLMathMasterGameCategory.random()
        
        return MLMathMasterQuestion(
                            value1: getValue1(),
                            value2: getValue2(index: i),
                            category: category)
    }

    /// Generate a value for `value1` based on the `base` value in `gameData`.
    /// If the `base` value is a single value we just return that value.. otherwise we randomize between the values in the `base` array
    /// - Returns: <#description#>
    private func getValue1() -> Int {
        if let gameData = gameData {
            if gameData.base.count == 1 {
                return gameData.base[0]
            } else {
                return gameData.base[Int.random(in: 0...gameData.base.count-1)]
            }
        } else {
            print("No GameData \(#function)")
            return 0
        }
    }
    
    
    /// Generate a value for `value2` based on the `type` value in `gameData`
    /// If it is a `.sequence` we just return the `index` supplied to the method otherwise (not sequence) we randomize the number
    /// - Parameter index: <#index description#>
    /// - Returns: <#description#>
    private func getValue2(index: Int) -> Int {
        if let gameData = gameData {
            switch gameData.type {
            case .sequence:
                return index - 1
            case .random(let max):
                return Int.random(in: 1...max)
            case .timeAttack(let max):
                return Int.random(in: 1...max)
            }
        } else {
            print("No GameData \(#function)")
            return 0
        }
    }
    
    
    /// Remove the evaluated question from the list of unanswered questions
    /// - Parameter question: the question to be removed
    private func removeQuestionFromRemaining(question: MLMathMasterQuestion) {
        let index = self.unansweredQuestions.firstIndex { q -> Bool in
            q.id == question.id
        }
        if let index = index {
            self.unansweredQuestions.remove(at: index)
        }
    }
    
    
    /// Adds the result to the question.. the reason for this is that its value typed and I could not get the value back in a nice way..
    /// - Parameters:
    ///   - question: the question that will get a result struct
    ///   - result: the result struct
    private func addResultToQuestion(question: MLMathMasterQuestion, result: MLMathMasterQuestionResult) {
        let index = self.questions.firstIndex { (q) -> Bool in
            q.id == question.id
        }
        if let index = index {
                self.questions[index].result = result
        }
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
    
    private func isLast(question: MLMathMasterQuestion) -> Bool {
        return self.questions[questions.count - 1] == question
    }
    
    private func newTimeAttackGame(category: MLMathMasterGameCategory, type: MLMathMasterGameType, base: [Int], timeAttackTime: MLMathMasterGameTimeAttackTime) {
        
        self.gameData = MLMathMasterGameData(category: category, type: type, base: base, timeAttackTime: timeAttackTime)

        self.noOfFetchedQuestions = 0
        self.gameState = .initialized
    }
    
    private func getTimeAttackQuestion() -> MLMathMasterQuestion{
        var q: MLMathMasterQuestion
        do {
            q = generateNewQuestion(index: nil)
            try self._activate(question: q)
            self.questions.append(q)
        } catch {
            print("Unresolved error generating TimeAttackQuestion. \(error), \(error.localizedDescription)")
        }
        return q
    }
    
    
    private func _activate(question: MLMathMasterQuestion) throws {
        
        if currentQuestion  != nil && currentQuestion?.result == nil {
            throw MLMathMasterEngineError.activateQuestionWhenPreviousQuestionIsNotEvaluated
        }
        
        currentQuestion = question
        question.active = true
        
        if self.gameState != .started,   !self.gameData!.type.isTimeAttack {
            self.gameState = .started
        }
    }
    
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
    public func newGame(
        category: MLMathMasterGameCategory,
        max: Int,
        base: [Int],
        timeAttackTime: MLMathMasterGameTimeAttackTime) {
            newTimeAttackGame(category: category,
                              type: .timeAttack(max),
                              base: base,
                              timeAttackTime: timeAttackTime)
    }
    
    public func newGame(
        category: MLMathMasterGameCategory,
        type: MLMathMasterGameType,
        base: [Int],
        noOfQuestions: Int? = nil) {
       
        self.gameData = MLMathMasterGameData(category: category, type: type, base: base)
        generateNewQuestions(count: noOfQuestions ?? self.settings.noOfQuestions)
        self.noOfFetchedQuestions = 0
        self.gameState = .initialized
    }
    
    
    
    /// Returns questions specified by `count`. If there is not enough questions for `count` it will return what is left. If there are no more questions to return it will return `nil`
    /// The private property `noOfFetchedQuestions` keeps track of how many questions have been delivered
    /// The default value for `count` is one.. meaning that if count is not specified it will return one question
    /// - Parameter count: The maximum numbers of questions we want to get
    /// - Returns: Optional array of questions. Max will be `count`. If there is not enough questions left to satisfy `count` the remaing questions are returned. If there are no more questions to return it will return nil
    public func getQuestions(by count: Int) throws -> [MLMathMasterQuestion]? {
       
        if case .timeAttack = self.gameData!.type {
            throw MLMathMasterEngineError.notAllowedInTimeAttack
        }
        
        guard questions.count > self.noOfFetchedQuestions else {
            return nil
        }
        
        let nextIndex = self.noOfFetchedQuestions
        /// get count questions OR if there is not enough get the rest
        let actualCount = min(questions.count - self.noOfFetchedQuestions, count)
        self.noOfFetchedQuestions += count

        return Array(questions[nextIndex..<nextIndex + actualCount])
    }

    public func getQuestions() throws -> [MLMathMasterQuestion]? {
        if case .timeAttack = self.gameData!.type {
            throw MLMathMasterEngineError.notAllowedInTimeAttack
        }
        return self.questions
    }

    
    /// Get a single question. self.noOfFetchedQuestions will be incremented. If there are no more questions this method returns nil
    /// - Returns: One question if there are questions left.. otherwise nil
    public func getQuestion() -> MLMathMasterQuestion? {
        if case .timeAttack = self.gameData!.type {
            if self.gameState != .timeAttackStarted {
                self.gameState = .timeAttackStarted
            }
            return getTimeAttackQuestion()
        }
        
        guard questions.count > self.noOfFetchedQuestions else {
            // we passed the last question and therefore stop the global time
            currentQuestion = nil
            stopGame()
            return nil
        }
        
        
        let index = self.noOfFetchedQuestions
        self.noOfFetchedQuestions += 1
        
        
        return questions[index]
    }
    
    
    /// Evaluates a MLMathMasterQuestion by calling `getResultOf` that returns the answer
    /// It then creates a result-struct (MLMathMasterQuestionResult), attaches the result to the question,
    /// removes the question from `unansweredQuestions` and returns the result
    /// - Parameters:
    ///   - question: the question to evaluate
    ///   - answer: the players answer
    /// - Returns: A MLMathMasterQuestionResult containing the result
    public func evaluateQuestion(question: inout MLMathMasterQuestion, answer: Int) throws -> MLMathMasterQuestionResult? {
        guard question.active == true else {
            throw MLMathMasterEngineError.evaluateQuestionBeforeItsActivated
        }
        
        let correctAnswer = getResultOf(question: question)
        let result = MLMathMasterQuestionResult(
            answer: answer,
            expectedAnswer: correctAnswer)
        addResultToQuestion(question: question, result: result)
        removeQuestionFromRemaining(question: question)
        question.active = false
        
        if !self.gameData!.type.isTimeAttack, isLast(question: question) {
            stopGame()
        }
        return result
    }
    
    public func activate(question: MLMathMasterQuestion) throws {
        
        if self.gameData!.type.isTimeAttack {
            throw MLMathMasterEngineError.notAllowedInTimeAttack
        }
        
        try _activate(question: question)
    }
    
    public func stopGame() {
        self.gameState = .stopped
    }
    
    
    
}
