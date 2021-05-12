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
final class GameFlowTest: XCTestCase {
    // MARK: - Normal sequential game
    let a = {
        
    }
    // MARK: - Init game
    
    // MARK: - Start new game
    func testStartNewGame() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])
        XCTAssert(engine.gameState == .initialized)
        XCTAssertNotNil(engine.gameData)
        XCTAssertNotNil(engine.settings)
        XCTAssertTrue(engine.qm!.unansweredQuestions == engine.settings.noOfQuestions )
        XCTAssertTrue(engine.qm!.answeredQuestions.count == 0)
        XCTAssertTrue(engine.qm!.noOfRightAnswers == 0)
        XCTAssertTrue(engine.qm!.gameData.noOfQuestions == engine.settings.noOfQuestions)
        XCTAssertNil(engine.startTime)
        XCTAssertNil(engine.stopTime)
        XCTAssertTrue(engine.totalTime == -1)
    }
    
    // MARK: - Run add sequence base 2 game
    func testRunGame() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])
        
        let expectation = self.expectation(description: "TestRunDone")
        let wrongAnswerIndex = 7
        var currentIndex = 0
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            currentIndex += 1
            do {
                try engine.qm!.activateNextQuestion()
                if let q = engine.qm!.currentQuestion {
                    let answer = q.value1 + q.value2
                    let _ = try engine.qm!.evaluateQuestion(answer: currentIndex == wrongAnswerIndex ? 90000000 : answer)
                    print(q.result!.answer)
                } else {
                    expectation.fulfill()
                    timer.invalidate()
                }
            } catch {
                XCTFail()
            }
        }
        
        self.waitForExpectations(timeout: 12) { _ in
            
            XCTAssertTrue(engine.gameState == .stopped)
            XCTAssertTrue(engine.qm!.answeredQuestions.count == engine.qm!.gameData.noOfQuestions)
            var isActive =  false
            var doesHaveStartAndStopTime = true
            var totalTime: Double = 0
            
            engine.qm!.answeredQuestions.forEach { (q) in
                isActive = isActive || q._active
                print("q starttime = \(String(describing: q.startTime)) stopTime: \(String(describing: q.stopTime))")
                doesHaveStartAndStopTime = doesHaveStartAndStopTime
                    && q.stopTime != nil
                    && q.startTime != nil
                totalTime += q.totalTime
            }
            XCTAssertFalse(isActive)
            XCTAssertTrue(doesHaveStartAndStopTime)
            XCTAssertNotNil(engine.startTime)
            XCTAssertNotNil(engine.stopTime)
            XCTAssertEqual(round(totalTime), round(engine.totalTime), "calculated Total time \(round(totalTime))(based on totalTime on question) should be equal to engines totalTime \(round(engine.totalTime))" )
            XCTAssertEqual(engine.qm!.answeredQuestions.count, engine.qm!.gameData.noOfQuestions)
            XCTAssertEqual(engine.qm!.noOfRightAnswers, engine.qm!.answeredQuestions.count - 1)
            
            
        }
    }
    
    // MARK: - TimeAttack random game with subtraction and base 2,4,6
    let b = {
        
    }
    
    // MARK: - Start new game
    func testStartNewGameV2() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .subtract, type: .random(100), base: [2, 4, 6])
        XCTAssert(engine.gameState == .initialized)
        XCTAssertNotNil(engine.gameData)
        XCTAssertNotNil(engine.settings)
        XCTAssertTrue(engine.qm!.unansweredQuestions == engine.settings.noOfQuestions )
        XCTAssertTrue(engine.qm!.answeredQuestions.count == 0)
        XCTAssertTrue(engine.qm!.noOfRightAnswers == 0)
        XCTAssertTrue(engine.qm!.gameData.noOfQuestions == engine.settings.noOfQuestions)
        XCTAssertNil(engine.startTime)
        XCTAssertNil(engine.stopTime)
        XCTAssertTrue(engine.totalTime == -1)
    }
    
    // MARK: - Run add sequence base 2 game
    func testRunGameV2() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .subtract, type: .random(100), base: [2, 4, 6], noOfQuestions: 30)
        
        let expectation = self.expectation(description: "TestRunDone")
        let wrongAnswerIndex = 7
        var currentIndex = 0
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
            currentIndex += 1
            do {
                try engine.qm!.activateNextQuestion()
                if let q = engine.qm!.currentQuestion {
                    var answer: Int {
                        switch q.category {
                        case .add:
                            return q.value1 + q.value2
                        case .subtract:
                            return q.value1 - q.value2
                        case .multiply:
                            return q.value1 * q.value2
                        default:
                            return 0
                        }
                    }
                    let _ = try engine.qm!.evaluateQuestion(answer: currentIndex == wrongAnswerIndex ? 90000000 : answer)
                    print(q.result!.answer)
                } else {
                    expectation.fulfill()
                    timer.invalidate()
                }
            } catch {
                XCTFail()
            }
        }
        
        self.waitForExpectations(timeout: 15) { _ in
            
            XCTAssertTrue(engine.gameState == .stopped)
            XCTAssertTrue(engine.qm!.answeredQuestions.count == engine.qm!.gameData.noOfQuestions)
            var isActive =  false
            var doesHaveStartAndStopTime = true
            var totalTime: Double = 0
            engine.qm!.answeredQuestions.forEach { (q) in
                isActive = isActive || q._active
                print("q starttime = \(String(describing: q.startTime)) stopTime: \(String(describing: q.stopTime))")
                doesHaveStartAndStopTime = doesHaveStartAndStopTime
                    && q.stopTime != nil
                    && q.startTime != nil
                totalTime += q.totalTime
            }
            XCTAssertFalse(isActive)
            XCTAssertTrue(doesHaveStartAndStopTime)
            XCTAssertEqual(engine.qm!.answeredQuestions.count, 30)
            XCTAssertEqual(round(totalTime), round(engine.totalTime))
            XCTAssertEqual(engine.qm!.answeredQuestions.count, engine.qm!.gameData.noOfQuestions)
            XCTAssertEqual(engine.qm!.noOfRightAnswers, engine.qm!.answeredQuestions.count - 1)
            
            
        }
    }
    
    
    // MARK: - TimeAttackGame
    let c = {
        
    }
    // MARK: - Start new game
    func testStartNewGameTimeAttack() {
        let engine = MLMathMasterEngine()
        engine.newTimeAttackGame(category: .random, max: 100, base: [2,3,4], timeAttackTime: .oneMin)
        XCTAssert(engine.gameState == .initialized)
        XCTAssertNotNil(engine.gameData)
        XCTAssertTrue(engine.gameData!.type == .timeAttack(100))
        XCTAssertTrue(engine.gameData!.timeAttackTime == .oneMin)
        XCTAssertNotNil(engine.settings)
        XCTAssertTrue(engine.qm!.unansweredQuestions == -1 ) // in timeAttack this value is -1
        XCTAssertTrue(engine.qm!.answeredQuestions.count == 0)
        XCTAssertTrue(engine.qm!.noOfRightAnswers == 0)
        XCTAssert(engine.currentTime == 0)
        XCTAssertNil(engine.startTime)
        XCTAssertNil(engine.stopTime)
        XCTAssertTrue(engine.totalTime == -1)
    }
    
    // MARK: - Run add sequence base 2 game
    func testRunGameTimeAttack() {
        let engine = MLMathMasterEngine()
        engine.newTimeAttackGame(category: .subtract, max: 100, base: [2,4,6], timeAttackTime: .test10Sek)
        
        let wrongAnswerIndex = 3
        var currentIndex = 0
                
        let timer = Timer.scheduledTimer(withTimeInterval: 2.1, repeats: true) { timer in
            currentIndex += 1
            do {
                // TODO: Fix the question .. for timeAttack.. right now there are no questions created
                try engine.qm!.activateNextQuestion()
                if let q = engine.qm!.currentQuestion {
                    var answer: Int {
                        switch q.category {
                        case .add:
                            return q.value1 + q.value2
                        case .subtract:
                            return q.value1 - q.value2
                        case .multiply:
                            return q.value1 * q.value2
                        default:
                            return 0
                        }
                    }
                    let _ = try engine.qm!.evaluateQuestion(answer: currentIndex == wrongAnswerIndex ? 90000000 : answer)
                    print(q.result!.answer)
                }
                XCTAssertTrue(engine.gameState == .timeAttackStarted)
            } catch {
                XCTFail()
            }
        }

        // Our expectation that will trigger on the TimeAttackEnd notification.
        let _ = self.expectation(forNotification: NSNotification.Name( MLMathMasterEngineNotifications.timeAttackEnd.rawValue), object: nil, handler: { notification -> Bool in
            timer.invalidate()
            return true
        })
        
        // Wait
        self.waitForExpectations(timeout: 4000) { _ in
            
            XCTAssertTrue(engine.gameState == .stopped)
            XCTAssert(engine.qm!.answeredQuestions.count < 7 && engine.qm!.answeredQuestions.count > 4)
            XCTAssertEqual(engine.qm!.noOfRightAnswers, engine.qm!.answeredQuestions.count - 1)
            
            
        }
    }
    
    @objc func userLoggedIn() {
        print(" In User Logged In")
    }
    
}


