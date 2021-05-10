//
//  QuestionStateTest.swift
//  MLMathMasterEngineTests
//
//  Created by Michael Lekrans on 2021-05-09.
//

import XCTest
@testable import MLMathMasterEngine
@available(iOS 13.0, *)
class QuestionStateTest: XCTestCase {

    func testFetchedQuestionShouldBeInitialized() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])
        let q = engine.getQuestion()!
        XCTAssertTrue(q._active == false)
        XCTAssertTrue(q.category == .add)
        XCTAssertNil(q.result)
        XCTAssertNil(q.startTime)
        XCTAssertNil(q.stopTime)
        XCTAssert(q.totalTime == -1.0)
    }
    
    func testSettingQuestionActiveChangeStateAndStartTime() {
        do {
            let engine = MLMathMasterEngine()
            engine.newGame(category: .add, type: .sequence, base: [2])
            let q = engine.getQuestion()!
            try engine.activate(question: q)
            XCTAssertTrue(q._active)
            XCTAssertNotNil(q.startTime)
            XCTAssertNil(q.stopTime)
        } catch {
            XCTFail()
        }

    }
    
    func testEvaluateQuestionThatIsNotActivatedResultsInError() throws {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])
        var q = engine.getQuestion()!
        XCTAssertThrowsError(try engine.evaluateQuestion(question: &q, answer: 3))
    }
    
    func testActivateNewQuestionWhenActivatedQuestionIsNotEvaluatedResultInNil() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])
        let caughtError: Error?
        
        do {
            let q = engine.getQuestion()!
            try engine.activate(question: q)
            let q2 = engine.getQuestion()!
            try engine.activate(question: q2)
            XCTFail()
        } catch {
            caughtError = error
            print("Unresolved error \(error) \(error.localizedDescription)")
            XCTAssertNotNil(caughtError)
            XCTAssertTrue(caughtError is MLMathMasterEngineError)
        }
    }
    
    // MARK: - Question Stats (answered, unanswered)
    func testGameResultShouldShowOneWronglyAnsweredQuestionOf10() {
        do {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])
        if var question = engine.getQuestion() {
            try engine.activate(question: question)
            let _ = try engine.evaluateQuestion(question: &question, answer: 3000)
        }
        
        XCTAssert(engine.answeredQuestions == 1, "answeredQuestions should be 1 was \(engine.answeredQuestions)")
        XCTAssert(engine.noOfRightAnswers == 0, "noOfRightAnswers should be 0, was \(engine.noOfRightAnswers)")
        } catch {
            XCTFail()
        }
        
    }

    
    func testGameResultShouldShowOneWronglyandOneRightAnsweredQuestionOf10() {
        do {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])
        if var question = engine.getQuestion() {
            print("Question \(question)")
            try engine.activate(question: question)
            let _ = try engine.evaluateQuestion(question: &question, answer: 3000)
        }
        if var question = engine.getQuestion() {
            print("Question \(question)")
            try engine.activate(question: question)
            let _ = try engine.evaluateQuestion(question: &question, answer: 3)
            print("Question after \(question)")
        }

        XCTAssert(engine.answeredQuestions == 2, "answeredQuestions should be 2 was \(engine.answeredQuestions)")
        XCTAssert(engine.noOfRightAnswers == 1, "noOfRightAnswers should be 1, was \(engine.noOfRightAnswers)")
        } catch {
            XCTFail()
        }
    }
    

}
