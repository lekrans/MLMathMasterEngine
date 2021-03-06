//
//  File.swift
//
//
//  Created by Michael Lekrans on 2021-05-10.
//

import Foundation
import XCTest
@testable import MLMathMasterEngine

@available(iOS 13.0, *)
final class TimeAttackTest: XCTestCase {
    // MARK: - new game
    func testStartNewGameTimeAttack() {
        let engine = MLMathMasterEngine()
        engine.newTimeAttackGame(category: .random, max: 100, base: [2,3,4], timeAttackTime: .oneMin)
        XCTAssert(engine.gameState == .initialized)
        XCTAssertNotNil(engine.gameData)
        XCTAssertTrue(engine.gameData!.type == .timeAttack(100))
        XCTAssertTrue(engine.gameData!.timeAttackTime == .oneMin)
        XCTAssertNotNil(engine.settings)
        XCTAssertTrue(engine.qm!.unansweredQuestions == -1 )
        XCTAssertTrue(engine.qm!.answeredQuestions.count == 0)
        XCTAssertTrue(engine.qm!.noOfRightAnswers == 0)
        XCTAssert(engine.currentTime == 0)
        XCTAssertNil(engine.startTime)
        XCTAssertNil(engine.stopTime)
        XCTAssertTrue(engine.totalTime == -1)
    }
    // MARK: - Start game
    func testGetFirstQuestionShouldActivateQuestionAndSetStateToTimeAttackStarted() throws {
        let engine = MLMathMasterEngine()
        engine.newTimeAttackGame(category: .random, max: 100, base: [1,2,3], timeAttackTime: .test10Sek)
        
        try engine.qm!.activateNextQuestion()
        let q = engine.qm!.currentQuestion!
        
        XCTAssertTrue(engine.gameData!.type.isTimeAttack)
        XCTAssertTrue(q._active)
        XCTAssertEqual(engine.gameState, .timeAttackStarted)
    }
    
    func testTimerShouldStartWhenStateIsTimeAttackStartedAndStopAfterGivenTime() throws {
        let engine = MLMathMasterEngine()
        engine.newTimeAttackGame(category: .random, max: 100, base: [1,2,3], timeAttackTime: .test10Sek)
        
        let timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { timer in
            do {
                try engine.qm!.activateNextQuestion()
                let _ = try engine.qm!.evaluateQuestion(answer: 10000)
            } catch {
                print("Error")
            }
        }
        
        let _ = self.expectation(forNotification: NSNotification.Name(MLMathMasterEngineNotifications.timeAttackEnd.rawValue), object: nil, handler: { notification in
            print("In expectation")
            timer.invalidate()
            return true
        })
        
        waitForExpectations(timeout: 100, handler: nil)
        
        XCTAssert(engine.qm!.answeredQuestions.count < 5 && engine.qm!.answeredQuestions.count > 2)
        

    }
    // MARK: - Stop game
    // MARK: - Result
}
