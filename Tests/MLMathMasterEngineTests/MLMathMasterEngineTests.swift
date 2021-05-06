import XCTest
@testable import MLMathMasterEngine

@available(iOS 13.0, *)
final class MLMathMasterEngineTests: XCTestCase {
    func testCreateEngine() {
        let _ = MLMathMasterEngine()
    }

    func testCreatedEngineShouldHaveStatusNone() {
        let engine = MLMathMasterEngine()
        XCTAssert(engine.status == .none)
    }

    func testStartNewGameOfTypeAdd() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [1])
        XCTAssertNotNil(engine.gameData)
        XCTAssertTrue(engine.gameData!.category == .add)
    }
    

    func testStartNewGameOfTypeAddHasRightNumberOfQuestions() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [1])
        XCTAssertTrue(engine.settings.noOfQuestions == 10)
        XCTAssertTrue(engine.questions.count == 10, "no of questions should be 10 was \(engine.questions.count)")
    }
    
    func testStartNewGameOfTypeAddWithChangedNumberOfQuestionsProduceRightNumberOfQuestions() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [1], noOfQuestions: 74)
        XCTAssert(engine.questions.count == 74, "question count should be 74, was \(engine.questions.count)")
    }
    
    func testQuestionsHaveTwoValues() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [1])
        XCTAssertNotNil(engine.questions[0].value1)
        XCTAssertNotNil(engine.questions[0].value2)
    }
    
    
    // MARK: - Question generation - add
    
    func testQuestionGeneratedFromSequenceWithOneAsBase() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [1])
        for i in 0...9 {
            print("testing \(i)")
            XCTAssertTrue(engine.questions[i].value1 == 1 && engine.questions[i].value2 == i, "value1 should be 2 (was \(String(describing: engine.questions[i].value1)), value2 should be \(i) (was \(String(describing: engine.questions[i].value2)))")
        }
    }

    func testQuestionGeneratedFromSequenceWithTwoAsBase() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])
        
        for i in 0...9 {
            print("testing \(i)")
            XCTAssertTrue(engine.questions[i].value1 == 2 && engine.questions[i].value2 == i, "value1 should be 2 (was \(String(describing: engine.questions[i].value1)), value2 should be \(i) (was \(String(describing: engine.questions[i].value2)))")
        }
    }

    
    func testQuestionGeneratedFromSequenceWithOneAndFourAndSixAsBase() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [1, 4, 6], noOfQuestions: 100)

        var noOfOnes: Int = 0
        var noOfFours: Int = 0
        var noOfSixs: Int = 0
        var otherNumberFound = false

        for i in 0...99 {
            print("testing \(i)")
            let question = engine.questions[i]
            let value1 = question.value1
            let value2 = question.value2
            
            switch value1 {
            case 1:
                noOfOnes += 1
            case 4:
                noOfFours += 1
            case 6:
                noOfSixs += 1
            default:
                otherNumberFound = true
            }

            XCTAssertTrue(value1 == 1 || value1 == 4 || value1 == 6  && engine.questions[i].value2 == i, "value1 should be 1, 4 or 6 (was \(String(value1)), value2 should be \(i) (was \(String(describing: value2)))")
        }
        XCTAssertFalse(otherNumberFound, "otherNumbersFound should be false.. was true")
        XCTAssert(noOfOnes > 0, "NoOfOnes should be greater than 0.. was \(noOfOnes)")
        XCTAssert(noOfFours > 0, "NoOfFours should be greater than 0.. was \(noOfFours)")
        XCTAssert(noOfSixs > 0, "NoOfSixs should be greater than 0.. was \(noOfSixs)")
    }
    
    
    // MARK: - .... subtract
    func testQuestionGeneratedFromSequenceWithOneAsBaseSubtract() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .subtract, type: .sequence, base: [1])
        for i in 0...9 {
            print("testing \(i)")
            XCTAssertTrue(engine.questions[i].value1 == 1 && engine.questions[i].value2 == i, "value1 should be 2 (was \(String(describing: engine.questions[i].value1)), value2 should be \(i) (was \(String(describing: engine.questions[i].value2)))")
        }
    }

    func testQuestionGeneratedFromSequenceWithTwoAsBaseSubtract() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .subtract, type: .sequence, base: [2])
        
        for i in 0...9 {
            print("testing \(i)")
            XCTAssertTrue(engine.questions[i].value1 == 2 && engine.questions[i].value2 == i, "value1 should be 2 (was \(String(describing: engine.questions[i].value1)), value2 should be \(i) (was \(String(describing: engine.questions[i].value2)))")
        }
    }

    
    func testQuestionGeneratedFromSequenceWithOneAndFourAndSixAsBaseSubtract() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .subtract, type: .sequence, base: [1, 4, 6], noOfQuestions: 100)

        var noOfOnes: Int = 0
        var noOfFours: Int = 0
        var noOfSixs: Int = 0
        var otherNumberFound = false

        for i in 0...99 {
            print("testing \(i)")
            let question = engine.questions[i]
            let value1 = question.value1
            let value2 = question.value2
            
            switch value1 {
            case 1:
                noOfOnes += 1
            case 4:
                noOfFours += 1
            case 6:
                noOfSixs += 1
            default:
                otherNumberFound = true
            }

            XCTAssertTrue(value1 == 1 || value1 == 4 || value1 == 6  && engine.questions[i].value2 == i, "value1 should be 1, 4 or 6 (was \(String(value1)), value2 should be \(i) (was \(String(describing: value2)))")
        }
        XCTAssertFalse(otherNumberFound, "otherNumbersFound should be false.. was true")
        XCTAssert(noOfOnes > 0, "NoOfOnes should be greater than 0.. was \(noOfOnes)")
        XCTAssert(noOfFours > 0, "NoOfFours should be greater than 0.. was \(noOfFours)")
        XCTAssert(noOfSixs > 0, "NoOfSixs should be greater than 0.. was \(noOfSixs)")
    }
    
    
    // MARK: - GetQuestions
    
    func testGetGroupOfQuestionsSpecifiedByCount5() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2], noOfQuestions: 12)
        
        var noOfQuestions = 0
        var noOfIterations = 0
        var noOfQuestionsLastTime = 0
        while let questions = engine.getQuestions(by: 5) {
            noOfQuestionsLastTime = questions.count
            noOfIterations += 1
            print("Batch-----------------")
            questions.forEach { question in
                noOfQuestions += 1
                print("question \(question.value1) + \(question.value2)")
            }
        }
        XCTAssert(noOfQuestions == 12, "NoOfQuestions should be 12 was \(noOfQuestions)")
        XCTAssert(noOfIterations == 3, "NoOfIterations should be 3 was \(noOfIterations)")
        XCTAssert(noOfQuestionsLastTime == 2, "NoOfQuestionsLastTime should be 2, was \(noOfQuestionsLastTime)")
    }

    func testGetGroupOfQuestionsSpecifiedByCountDefault() {
        // Should return ALL questions
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2], noOfQuestions: 12)
        
        let questions = engine.getQuestions()!
        XCTAssert(questions.count == 12, "questions count should be 12, was \(questions.count)")
    }

    
    func testGetSingleQuestion() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])

        var noOfQuestions = 0
        while let _ = engine.getQuestion() {
            noOfQuestions += 1
        }
        
        XCTAssert(noOfQuestions == 10, "NoOfQuestions should be 10, was \(noOfQuestions)")
    }
    
    
    // MARK: - Evaluate question ... add
    
    func testEvaluateFirstQuestion() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])

        if var question = engine.getQuestion() {
            let result = engine.evaluateQuestion(question: &question, answer: 2)
            XCTAssert(result.success == true , "result.success should be true, was \(result.success)")
            XCTAssertEqual(result.answer, result.expectedAnswer)
        }
    }
    
    func testEvaluatedQuestionHaveAResultType() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])

        var question = engine.getQuestion()
        let _ = engine.evaluateQuestion(question: &question!, answer: 2)

        let index = engine.questions.firstIndex { (q) -> Bool in
            q.id == question!.id
        }
        XCTAssertNotNil(index)
        XCTAssertNotNil(engine.questions[index!].result)
    }
    
    func testEvaluateAllQuestionsOnAddAndBase2() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])

        var iteration = 0
        while var question = engine.getQuestion() {
            let answer = iteration + 2
            iteration += 1
            let result = engine.evaluateQuestion(question: &question, answer: answer)
            XCTAssert(result.success == true , "result.success should be true, was \(result.success)")
            XCTAssertEqual(result.answer, result.expectedAnswer)
        }
    }

    
    // MARK: - .... subtract
    
    func testEvaluateFirstQuestionSubtract() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .subtract, type: .sequence, base: [2])

        if var question = engine.getQuestion() {
            let result = engine.evaluateQuestion(question: &question, answer: 2)
            XCTAssert(result.success == true , "result.success should be true, was \(result.success)")
            XCTAssertEqual(result.answer, result.expectedAnswer)
        }
    }
    
    func testEvaluatedQuestionHaveAResultTypeSubtract() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .subtract, type: .sequence, base: [2])

        var question = engine.getQuestion()
        let _ = engine.evaluateQuestion(question: &question!, answer: 2)

        let index = engine.questions.firstIndex { (q) -> Bool in
            q.id == question!.id
        }
        XCTAssertNotNil(index)
        XCTAssertNotNil(engine.questions[index!].result)
    }
    
    func testEvaluateAllQuestionsOnAddAndBase2Subtract() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .subtract, type: .sequence, base: [2])

        var iteration = 0
        while var question = engine.getQuestion() {
            let answer = 2 - iteration
            iteration += 1
            let result = engine.evaluateQuestion(question: &question, answer: answer)
            XCTAssert(result.success == true , "result.success should be true, was \(result.success)")
            XCTAssertEqual(result.answer, result.expectedAnswer)
        }
    }

    
    // MARK: - .... multiply
    
    func testEvaluateFirstQuestionMultiply() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .multiply, type: .sequence, base: [2])

        if var question = engine.getQuestion() {
            let result = engine.evaluateQuestion(question: &question, answer: 0)
            XCTAssert(result.success == true , "result.success should be true, was \(result.success)")
            XCTAssertEqual(result.answer, result.expectedAnswer)
        }
    }
    
    func testEvaluatedQuestionHaveAResultTypeMultiply() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .multiply, type: .sequence, base: [2])

        var question = engine.getQuestion()
        let _ = engine.evaluateQuestion(question: &question!, answer: 0)

        let index = engine.questions.firstIndex { (q) -> Bool in
            q.id == question!.id
        }
        XCTAssertNotNil(index)
        XCTAssertNotNil(engine.questions[index!].result)
    }
    
    func testEvaluateAllQuestionsOnAddAndBase2Multiply() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .multiply, type: .sequence, base: [2])

        var iteration = 0
        while var question = engine.getQuestion() {
            let answer = 2 * iteration
            iteration += 1
            let result = engine.evaluateQuestion(question: &question, answer: answer)
            XCTAssert(result.success == true , "result.success should be true, was \(result.success)")
            XCTAssertEqual(result.answer, result.expectedAnswer)
        }
    }

    
    // MARK: - Question asString
    func testQuestionAsStringAdd() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])

        let question = engine.getQuestion()!
            
        XCTAssertEqual(question.asString(), "2 + 0")
    }

    
    func testQuestionAsStringSubtract() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .subtract, type: .sequence, base: [2])

        let question = engine.getQuestion()!
            
        XCTAssertEqual(question.asString(), "2 - 0")
    }
    
    func testQuestionAsStringMultiply() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .multiply, type: .sequence, base: [2])

        let question = engine.getQuestion()!
            
        XCTAssertEqual(question.asString(), "2 * 0")
    }


    
    
    
    
    
    // MARK: - New Game -> Reset
    func testAllStateAndPropertiesOnEngineShouldBeResetedWithNewGame() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])

        var iteration = 0
        
        while var question = engine.getQuestion() {
            let answer = iteration + 2
            iteration += 1
            let _ = engine.evaluateQuestion(question: &question, answer: answer)
        }
        
        engine.newGame(category: .add, type: .sequence, base: [3])
        XCTAssert(engine.status == .initialized)
        XCTAssert(engine.questions.count == 10)
        XCTAssert(engine.unansweredQuestions.count == 10)
        XCTAssert(engine.answeredQuestions == 0)
        XCTAssert(engine.noOfRightAnswers == 0)
    }
    
    
    // MARK: - Question Stats (answered, unanswered)
    func testGameResultShouldShowOneWronglyAnsweredQuestionOf10() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])
        if var question = engine.getQuestion() {
            let _ = engine.evaluateQuestion(question: &question, answer: 3000)
        }
        
        XCTAssert(engine.answeredQuestions == 1, "answeredQuestions should be 1 was \(engine.answeredQuestions)")
        XCTAssert(engine.noOfRightAnswers == 0, "noOfRightAnswers should be 0, was \(engine.noOfRightAnswers)")
        
    }

    
    func testGameResultShouldShowOneWronglyandOneRightAnsweredQuestionOf10() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])
        if var question = engine.getQuestion() {
            print("Question \(question)")
            let _ = engine.evaluateQuestion(question: &question, answer: 3000)
        }
        if var question = engine.getQuestion() {
            print("Question \(question)")
            let _ = engine.evaluateQuestion(question: &question, answer: 3)
            print("Question after \(question)")
        }

        XCTAssert(engine.answeredQuestions == 2, "answeredQuestions should be 2 was \(engine.answeredQuestions)")
        XCTAssert(engine.noOfRightAnswers == 1, "noOfRightAnswers should be 1, was \(engine.noOfRightAnswers)")
    }
    
    
    // MARK: - Time and active
    
    func testActiveQuestionStartTimeOnQuestion() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])
        let question = engine.getQuestion()! // remember that it is valueType
        XCTAssert(question.startTime == nil, "StartTime should be nil")
        engine.activate(question: question)
        XCTAssert(question.startTime != nil, "StartTime should have a value, was nil")
        XCTAssert(question.stopTime == nil, "stopTime should be nil")
    }

    func testEvaluateActiveQuestionDeactivatesQuestion() {
        // activating the next question should stop the previous one
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])
        var question = engine.getQuestion()! // remember that it is valueType
        engine.activate(question: question)
        XCTAssert(question.startTime != nil, "StartTime should NOT be nil")
        XCTAssert(question.stopTime == nil, "StartTime should be nil")
        let _ = engine.evaluateQuestion(question: &question, answer: 23)
        XCTAssert(question.startTime != nil, "StartTime should have a value, was nil")
        XCTAssert(question.stopTime != nil, "stopTime should have a value, was nil")
    }

    
    func testActivateAnotherQuestionChangeStateOnPreviousQuestion() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])
        let question = engine.getQuestion()! // remember that it is valueType
        engine.activate(question: question)
        let question2 = engine.getQuestion()! // remember that it is valueType
        engine.activate(question: question2)
        XCTAssertNotNil(question.startTime, "StartTime Should have a value.. was nil")
        XCTAssertNotNil(question2.startTime, "StartTime Should have a value.. was nil")
        XCTAssertFalse(question.active, "Running on question should be false")
        XCTAssertTrue(question2.active, "Running on question2 should be true")
        XCTAssertNotNil(question.stopTime, "Question stoptime should have a value, was nil")
        XCTAssertNil(question2.stopTime, "Question2 stoptime should be nil")
    }

    func testGetQuestionBeyondScopeShouldDeactivateLastQuestionAndSetStopTime() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])
        let q1 = engine.getQuestion()! // remember that it is valueType
        engine.activate(question: q1)
        let q2 = engine.getQuestion()! // remember that it is valueType
        engine.activate(question: q2)
        let q3 = engine.getQuestion()! // remember that it is valueType
        engine.activate(question: q3)
        let q4 = engine.getQuestion()! // remember that it is valueType
        engine.activate(question: q4)
        let q5 = engine.getQuestion()! // remember that it is valueType
        engine.activate(question: q5)
        let q6 = engine.getQuestion()! // remember that it is valueType
        engine.activate(question: q6)
        let q7 = engine.getQuestion()! // remember that it is valueType
        engine.activate(question: q7)
        let q8 = engine.getQuestion()! // remember that it is valueType
        engine.activate(question: q8)
        let q9 = engine.getQuestion()! // remember that it is valueType
        engine.activate(question: q9)
        let question10 = engine.getQuestion()! // remember that it is valueType
        engine.activate(question: question10)
        let question11 = engine.getQuestion() // remember that it is valueType
        if question11 != nil {
            engine.activate(question: question11!)
        }
        XCTAssertNil(question11, "question11 should be nil")
        XCTAssertNotNil(question10.startTime, "StartTime Should have a value.. was nil")
        XCTAssertFalse(question10.active, "Running on question should be false")
        XCTAssertNotNil(question10.stopTime, "Question2 stoptime should NOT be nil")
    }
    
    func testQuestionTime() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])
        var q1 = engine.getQuestion()!
        engine.activate(question: q1)
        
        let expectation = self.expectation(description: "Answer")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.1) {
            let _ = engine.evaluateQuestion(question: &q1, answer: 3)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        let timeDifference = q1.totalTime
        print("timeDifference = \(timeDifference)")
        XCTAssert( timeDifference >= 3, "Time should be 3 sek or more.. was \(timeDifference)")
    }
    
    func testQuestionTimeTotalWithTotalTimeStopOnGetQuestionBeyondRange() {
        // stopTime should be set when we call getQuestion last time and get nil back
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])

        let expectation = self.expectation(description: "Answer")
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            let q = engine.getQuestion()
            
            if let q = q {
                engine.activate(question: q)
            } else {
                timer.invalidate()
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 12, handler: nil)
        
        XCTAssert(engine.totalTime > 9, "TotalTime Should be greate than 9 was \(engine.totalTime)")
    }
    
    func testQuestionTotalTimeAfterExplicitStopGame() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])
        
        let questions = engine.getQuestions()!
        var nextQuestion = 0
        
        let expectation = self.expectation(description: "Answer")
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            print("question count \(questions.count)")
            
            if nextQuestion < questions.count {
                engine.activate(question: questions[nextQuestion])
                nextQuestion += 1
            } else {
                engine.stopGame()
                timer.invalidate()
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 12, handler: nil)
        
        XCTAssert(engine.totalTime > 9, "TotalTime Should be greate than 9 was \(engine.totalTime)")

    }
    
    
    // MARK: - Game State
    
    func testGameStateNoneAtStart() {
        let engine = MLMathMasterEngine()
        XCTAssert(engine.status == .none)
    }
    
    func testGameStateInitializedAtNewGame() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .subtract, type: .sequence, base: [2])
        XCTAssert(engine.status == .initialized)
    }
    
    func testGameStateStartedAfterActivatingFirstQuestion() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .subtract, type: .sequence, base: [2])
        let q = engine.getQuestion()!
        engine.activate(question: q)
        XCTAssert(engine.status == .started)
    }

    
    func testGameStateStoppedAfterLastQuestion() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .subtract, type: .sequence, base: [2])
        
        
        for i in 0...10 { // one more than number of questions
            
            if let q = engine.getQuestion() {
                engine.activate(question: q)
            }
        }
                
        XCTAssert(engine.status == .stopped)
    }
    
    func testAllQuestionsAnsweredShouldSetStateToStopped() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])

        var iteration = 0
        let unansweredQuestionsAtBeginning = engine.unansweredQuestions.count
        
        while var question = engine.getQuestion() {
            let answer = iteration + 2
            iteration += 1
            let _ = engine.evaluateQuestion(question: &question, answer: answer)
        }
        
        XCTAssert(engine.status == .stopped, "status should be .stopped .. was \(engine.status)")
        XCTAssert(unansweredQuestionsAtBeginning == 10, "unansweredQuestionsAtBeginning should be 10, was \(unansweredQuestionsAtBeginning)")
        XCTAssert(engine.unansweredQuestions.count == 0, "unansweredQuestions should be 0, was \(engine.unansweredQuestions.count)")

    }
    

    func testSingleQuestionFirstActivatedSetsGameStateToStarted() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])
        let question = engine.getQuestion()
        XCTAssert(engine.status == .initialized)
        engine.activate(question: question!)
        XCTAssert(engine.status == .started, "Should be .started, was \(engine.status)")
    }
    
    func testBatchQuestionFetchActivateFirstSetGameStateToStarted() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])
        let questions = engine.getQuestions(by: 5)
        XCTAssert(engine.status == .initialized)
        engine.activate(question: questions![0])
        XCTAssert(engine.status == .started)
    }
    
    func testFetchAllQuestionFetchActivateFirstSetGameStateToStarted() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])
        let questions = engine.getQuestions()
        XCTAssert(engine.status == .initialized)
        engine.activate(question: questions![0])
        XCTAssert(engine.status == .started)
    }
    
    func testAnswerLastQuestionShouldSetGameStatusToStopped() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])

        let questions = engine.getQuestions()
        XCTAssertTrue(engine.status == .initialized)
        engine.activate(question: questions![0])
        XCTAssertTrue(engine.status == .started)
        var lastQuestion = questions![questions!.count - 1]
        engine.activate(question: lastQuestion)
        engine.evaluateQuestion(question: &lastQuestion, answer: 2)
        XCTAssertTrue(engine.status == .stopped)
    }



    static var allTests = [
        ("testExample", testCreateEngine),
    ]
}


extension DispatchTime {
    var asSeconds: Double {
        Double(self.rawValue) / Double(1000000000)
    }
}
