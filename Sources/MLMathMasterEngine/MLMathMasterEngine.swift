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





// MARK: - GameType
/// Game Type: What type of game(test) we are doing, like .sequence (like tables), .random
@available(iOS 13.0, *)
public enum MLMathMasterGameType {
    case sequence
}






// MARK: - GameData
/// Game Data: Holds information about one game, like `category`, `type`, `base` and so on
@available(iOS 13.0, *)
public struct MLMathMasterGameData {
    var category: MLMathMasterGameCategory
    var type: MLMathMasterGameType
    var base: [Int] = []
}






// MARK: - GameStatus
@available(iOS 13.0, *)
public enum MLMathMasterGameStatus {
    case none, started, stopped
}






// MARK: - GameSettings
/// Game settings: settings for the MLMathMaster game
@available(iOS 13.0, *)
public struct MLMathMasterGameSettings {
    var noOfQuestions: Int = 10
}






// MARK: - Question
/// Question struct: Holds the information about one question
@available(iOS 13.0, *)
public class MLMathMasterQuestion: Identifiable {
    public var id = UUID()
    public var value1: Int
    public var value2: Int
    public var category: MLMathMasterGameCategory
    public var result: MLMathMasterQuestionResult?
    public var active: Bool = false {
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









// MARK: - Engine
/// The MLMathMaster game engine.
/// The controller of the game.
/// You initialize a new game by calling `func newGame()` and specify what type and category and so on you want to test
@available(iOS 13.0, *)
public class MLMathMasterEngine: ObservableObject {
    
    // MARK: - private properties
    var noOfFetchedQuestions: Int = 0
    var currentQuestion: MLMathMasterQuestion? {
        willSet {
            print("WILL SET")
            if currentQuestion != nil {
                currentQuestion!.active = false
                
            }
            newValue?.active = false
        }
    }
    // MARK: - public properties
    var gameData: MLMathMasterGameData?
    var settings: MLMathMasterGameSettings
    @Published var questions: [MLMathMasterQuestion] = []
    var unansweredQuestions: [MLMathMasterQuestion] = []
    var status: MLMathMasterGameStatus = .none

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
    
    public init(settings: MLMathMasterGameSettings? = nil) {
        self.settings = settings ?? MLMathMasterGameSettings()
    }
    
    
    
    
        
    // MARK: - Private methods
    
    
    /// Reset and regenerates new questions based on the `count` value. These questions are stored in the `self.questions` array
    /// - Parameter count: No of questions to produce
    private func generateNewQuestions(count: Int) {
        
        guard let gameData = self.gameData else {
            fatalError("No GameData when generating questions")
        }
        
        questions = []
        for i in 1...count {
            let category = gameData.category != .random ? gameData.category : MLMathMasterGameCategory.random()
            
            questions.append(MLMathMasterQuestion(
                                value1: getValue1(),
                                value2: getValue2(index: i),
                                category: category))
        }
        /// value semantic so this is a full copy
        self.unansweredQuestions = questions
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
            let value = gameData.type == .sequence ? index - 1: Int.random(in: 0...9)
            return value
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
            if self.unansweredQuestions.count == 0 {
                self.status = .stopped
            }
        }
    }
    
    
    /// Adds the result to the question.. the reason for this is that its value typed and I could not get the value back in a nice way..
    /// - Parameters:
    ///   - question: the question that will get a result struct
    ///   - result: the result struct
    func addResultToQuestion(question: MLMathMasterQuestion, result: MLMathMasterQuestionResult) {
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
    func getResultOf(question: MLMathMasterQuestion) -> Int {
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
        type: MLMathMasterGameType,
        base: [Int],
        noOfQuestions: Int? = nil) {
        self.gameData = MLMathMasterGameData(category: category, type: type, base: base)
        generateNewQuestions(count: noOfQuestions ?? self.settings.noOfQuestions)
        self.noOfFetchedQuestions = 0
        self.status = .started
    }
    
    
    /// Returns questions specified by `count`. If there is not enough questions for `count` it will return what is left. If there are no more questions to return it will return `nil`
    /// The private property `noOfFetchedQuestions` keeps track of how many questions have been delivered
    /// The default value for `count` is one.. meaning that if count is not specified it will return one question
    /// - Parameter count: The maximum numbers of questions we want to get
    /// - Returns: Optional array of questions. Max will be `count`. If there is not enough questions left to satisfy `count` the remaing questions are returned. If there are no more questions to return it will return nil
    public func getQuestions(by count: Int = 1) -> [MLMathMasterQuestion]? {
        guard questions.count > self.noOfFetchedQuestions else {
            return nil
        }
        
        let nextIndex = self.noOfFetchedQuestions
        /// get count questions OR if there is not enough get the rest
        let actualCount = min(questions.count - self.noOfFetchedQuestions, count)
        self.noOfFetchedQuestions += count

        return Array(questions[nextIndex..<nextIndex + actualCount])
    }
    
    
    /// Get a single question. self.noOfFetchedQuestions will be incremented. If there are no more questions this method returns nil
    /// - Returns: One question if there are questions left.. otherwise nil
    public func getQuestion() -> MLMathMasterQuestion? {
        guard questions.count > self.noOfFetchedQuestions else {
            currentQuestion = nil
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
    ///   - question: <#question description#>
    ///   - answer: <#answer description#>
    /// - Returns: <#description#>
    public func evaluateQuestion(question: inout MLMathMasterQuestion, answer: Int) -> MLMathMasterQuestionResult {
        let correctAnswer = getResultOf(question: question)
        print("currectAnswer = \(correctAnswer)")
        print("Answer = \(answer)")
        print("category = \(question.category)")
        let result = MLMathMasterQuestionResult(
            answer: answer,
            expectedAnswer: correctAnswer)
        addResultToQuestion(question: question, result: result)
        removeQuestionFromRemaining(question: question)
        question.active = false
        return result
    }
    
    public func activate(question: MLMathMasterQuestion) {
        currentQuestion = question
        question.active = true
    }
    
    
    
}
