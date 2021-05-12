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

    func testFetchedQuestionShouldBeInitialized() throws {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])
        try engine.qm!.activateNextQuestion()
        XCTAssertTrue(engine.qm!.currentQuestion!._active == true)
        XCTAssertTrue(engine.qm!.currentQuestion!.category == .add)
        XCTAssertNil(engine.qm!.currentQuestion!.result)
        XCTAssertNotNil(engine.qm!.currentQuestion!.startTime)
        XCTAssertNil(engine.qm!.currentQuestion!.stopTime)
        XCTAssert(engine.qm!.currentQuestion!.totalTime == -1.0)
    }
    
    func testSettingQuestionActiveChangeStateAndStartTime() {
        do {
            let engine = MLMathMasterEngine()
            engine.newGame(category: .add, type: .sequence, base: [2])
            try engine.qm!.activateNextQuestion()
            XCTAssertTrue(engine.qm!.currentQuestion!._active)
            XCTAssertNotNil(engine.qm!.currentQuestion!.startTime)
            XCTAssertNil(engine.qm!.currentQuestion!.stopTime)
        } catch {
            XCTFail()
        }

    }
    
    
    func testActivateNewQuestionWhenActivatedQuestionIsNotEvaluatedResultInNil() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])
        let caughtError: Error?
        
        do {
            try engine.qm!.activateNextQuestion()
            try engine.qm!.activateNextQuestion()
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
            try engine.qm!.activateNextQuestion()
            let _ = try engine.qm!.evaluateQuestion(answer: 3000)
        
        
            XCTAssert(engine.qm!.answeredQuestions.count == 1, "answeredQuestions should be 1 was \(engine.qm!.answeredQuestions.count)")
            XCTAssert(engine.qm!.noOfRightAnswers == 0, "noOfRightAnswers should be 0, was \(engine.qm!.noOfRightAnswers)")
        } catch {
            XCTFail()
        }
        
    }

    
    func testGameResultShouldShowOneWronglyandOneRightAnsweredQuestionOf10() {
        do {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])
            try engine.qm!.activateNextQuestion()
            let _ = try engine.qm!.evaluateQuestion(answer: 3000)
            try engine.qm!.activateNextQuestion()
            var question = engine.qm!.currentQuestion!
            var answer = question.value1 + question.value2
            let _ = try engine.qm!.evaluateQuestion(answer: answer)
            try engine.qm!.activateNextQuestion()
            question = engine.qm!.currentQuestion!
            answer = question.value1 + question.value2
            let _ = try engine.qm!.evaluateQuestion(answer: answer)

            XCTAssert(engine.qm!.answeredQuestions.count == 3, "answeredQuestions should be 2 was \(engine.qm!.answeredQuestions)")
            XCTAssert(engine.qm!.noOfRightAnswers == 2, "noOfRightAnswers should be 1, was \(engine.qm!.noOfRightAnswers)")
        } catch {
            XCTFail()
        }
    }
    

}
