//
//  File.swift
//  
//
//  Created by Michael Lekrans on 2021-05-09.
//

import Foundation
@testable import MLMathMasterEngine
import XCTest

@available(iOS 13.0, *)
final class GameStateTest: XCTestCase {
    
    // MARK: - Initialized
    func testCreatedEngineShouldHaveStatusNone() {
        let engine = MLMathMasterEngine()
        XCTAssert(engine.gameState == .none)
    }
    
    // MARK: - New Game Start
    func testNewGameStateShouldBeInitialized() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])
        XCTAssertEqual(engine.gameState, .initialized)
    }
    
    // MARK: - STATE = STARTED
    func testGameStateStartedAfterActivatingFirstQuestion() {
        do {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .subtract, type: .sequence, base: [2])
        let q = engine.getQuestion()!
        try engine.activate(question: q)
        XCTAssert(engine.gameState == .started)
        } catch {
            XCTFail()
        }
    }
    
    func testSingleQuestionFirstActivatedSetsGameStateToStarted() {
        do {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])
        let question = engine.getQuestion()
        XCTAssert(engine.gameState == .initialized)
        try engine.activate(question: question!)
        XCTAssert(engine.gameState == .started, "Should be .started, was \(engine.gameState)")
        } catch {
            XCTFail()
        }
    }
    
    func testBatchQuestionFetchActivateFirstSetGameStateToStarted() throws {
        do {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])
        let questions = try engine.getQuestions(by: 5)
        XCTAssert(engine.gameState == .initialized)
        try engine.activate(question: questions![0])
        XCTAssert(engine.gameState == .started)
        } catch {
            XCTFail()
        }
    }
    
    func testFetchAllQuestionFetchActivateFirstSetGameStateToStarted() throws {
        do {
            let engine = MLMathMasterEngine()
            engine.newGame(category: .add, type: .sequence, base: [2])
            let questions = try engine.getQuestions()
            XCTAssert(engine.gameState == .initialized)
            try engine.activate(question: questions![0])
            XCTAssert(engine.gameState == .started)
        } catch {
            XCTFail()
        }
    }
    
    func testTimeAttackGetQuestionShouldNotSetStateToStarted() throws {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .random, max: 100, base: [2,3,4], timeAttackTime: .oneMin)
        let _ = engine.getQuestion()!
        XCTAssertNotEqual(engine.gameState, .started)
    }
    
    
    // MARK: - STATE = STOPPED
    func testGameStateStoppedAfterLastQuestion() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .subtract, type: .sequence, base: [2])
        
        
        for _ in 0...10 { // one more than number of questions
            
            if var q = engine.getQuestion() {
                do {
                    try engine.activate(question: q)
                    let _ = try engine.evaluateQuestion(question: &q, answer: 4)
                } catch {
                    XCTFail()
                }
            }
        }
        
        XCTAssert(engine.gameState == .stopped)
    }
    
    func testAllQuestionsAnsweredShouldSetStateToStopped() {
        do {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])
        
        var iteration = 0
        let unansweredQuestionsAtBeginning = engine.unansweredQuestions.count
        
        while var question = engine.getQuestion() {
            let answer = iteration + 2
            iteration += 1
            try engine.activate(question: question)
            let _ = try engine.evaluateQuestion(question: &question, answer: answer)
        }
        
        XCTAssert(engine.gameState == .stopped, "status should be .stopped .. was \(engine.gameState)")
        XCTAssert(unansweredQuestionsAtBeginning == 10, "unansweredQuestionsAtBeginning should be 10, was \(unansweredQuestionsAtBeginning)")
        XCTAssert(engine.unansweredQuestions.count == 0, "unansweredQuestions should be 0, was \(engine.unansweredQuestions.count)")
        } catch {
            XCTFail()
        }
        
    }
    
    func testAnswerLastQuestionShouldSetGameStatusToStopped() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])
        
        do {
            var questions = try engine.getQuestions()
            XCTAssertTrue(engine.gameState == .initialized)
            try engine.activate(question: questions![0])
            let _ = try engine.evaluateQuestion(question: &questions![0], answer: 5)
            XCTAssertTrue(engine.gameState == .started)
            var lastQuestion = questions![questions!.count - 1]
            try engine.activate(question: lastQuestion)
            let _ = try engine.evaluateQuestion(question: &lastQuestion, answer: 2)
            XCTAssertTrue(engine.gameState == .stopped)
        } catch {
            XCTFail()
        }
    }

    // MARK: - STATE = TIMEATTACKSTARTED
//    func testGetFirstQuestionInTimeAttackSetStateToTimeAttackStarted() {
//        let engine = MLMathMasterEngine()
//        engine.newGame(category: .random, max: 100, base: [2,3,4], timeAttackTime: .test10Sek)
//        let q = engine.getQuestion()
//    }

}

