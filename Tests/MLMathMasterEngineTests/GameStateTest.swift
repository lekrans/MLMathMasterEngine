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
            
            try engine.qm!.activateNextQuestion()
            XCTAssert(engine.gameState == .started)
        } catch {
            XCTFail()
        }
    }
    
    func testSingleQuestionFirstActivatedSetsGameStateToStarted() {
        do {
            let engine = MLMathMasterEngine()
            engine.newGame(category: .add, type: .sequence, base: [2])
            XCTAssert(engine.gameState == .initialized)
            try engine.qm!.activateNextQuestion()
            
            XCTAssert(engine.gameState == .started, "Should be .started, was \(engine.gameState)")
        } catch {
            XCTFail()
        }
    }
    
    func testBatchQuestionFetchActivateFirstSetGameStateToStarted() throws {
        do {
            let engine = MLMathMasterEngine()
            engine.newGame(category: .add, type: .sequence, base: [2], groupSize: 5)
            XCTAssert(engine.gameState == .initialized)
            try engine.qm!.activateNextQuestion()
            XCTAssert(engine.gameState == .started)
        } catch {
            XCTFail()
        }
    }
    
    func testFetchAllQuestionFetchActivateFirstSetGameStateToStarted() throws {
        do {
            let engine = MLMathMasterEngine()
            engine.newGame(category: .add, type: .sequence, base: [2], groupSize: -1)
            XCTAssert(engine.gameState == .initialized)
            try engine.qm!.activateNextQuestion()
            XCTAssert(engine.gameState == .started)
        } catch {
            XCTFail()
        }
    }
    
    
    
    // MARK: - STATE = STOPPED
    func testGameStateStoppedAfterLastQuestion() throws {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .subtract, type: .sequence, base: [2])
        
        for _ in 0...10 { // one more than number of questions
            try engine.qm!.activateNextQuestion()
            if let _ = engine.qm!.currentQuestion {
                do {
                    let _ = try engine.qm!.evaluateQuestion(answer: 4)
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
            let unansweredQuestionsAtBeginning = engine.qm!.unansweredQuestions
            
            try engine.qm!.activateNextQuestion()
            while let _ = engine.qm!.currentQuestion {
                let answer = iteration + 2
                iteration += 1
                let _ = try engine.qm!.evaluateQuestion(answer: answer)
                try engine.qm!.activateNextQuestion()
            }
            
            XCTAssert(engine.gameState == .stopped, "status should be .stopped .. was \(engine.gameState)")
            XCTAssert(unansweredQuestionsAtBeginning == 10, "unansweredQuestionsAtBeginning should be 10, was \(unansweredQuestionsAtBeginning)")
            XCTAssert(engine.qm!.unansweredQuestions == 0, "unansweredQuestions should be 0, was \(engine.qm!.unansweredQuestions)")
        } catch {
            XCTFail()
        }
        
    }
    
    func testAnswerLastQuestionShouldSetGameStatusToStopped() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])
        
        do {
            while engine.gameState != .stopped {
                try engine.qm!.activateNextQuestion()
                try engine.qm!.evaluateQuestion(answer: 3)
            }
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

