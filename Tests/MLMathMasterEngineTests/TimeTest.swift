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
final class TimeTest: XCTestCase {
    // MARK: - Question time
    // Activate question sets startTime
    func testActiveQuestionStartTimeOnQuestion() {
        do {
            let engine = MLMathMasterEngine()
            engine.newGame(category: .add, type: .sequence, base: [2])
            try engine.qm!.activateNextQuestion()
            let question = engine.qm!.currentQuestion!
            XCTAssert(question.startTime != nil, "StartTime should have a value, was nil")
            XCTAssert(question.stopTime == nil, "stopTime should be nil")
        } catch {
            XCTFail()
        }
    }
    
    // Evaluate question set stopTime
    func testEvaluateActiveQuestionDeactivatesQuestion() {
        // activating the next question should stop the previous one
        do {
            let engine = MLMathMasterEngine()
            engine.newGame(category: .add, type: .sequence, base: [2])
            try engine.qm!.activateNextQuestion()
            let question = engine.qm!.currentQuestion! // remember that it is valueType
            
            XCTAssert(question.startTime != nil, "StartTime should NOT be nil")
            XCTAssert(question.stopTime == nil, "StartTime should be nil")
            
            let _ = try engine.qm!.evaluateQuestion(answer: 23)
            XCTAssert(question.startTime != nil, "StartTime should have a value, was nil")
            XCTAssertTrue(question.evaluated)
            XCTAssertNotNil(engine.qm!.currentQuestion?.stopTime)
            XCTAssert(question.stopTime != nil, "stopTime should have a value, was nil")
            
        } catch {
            XCTFail()
        }
    }
    
    
    
    // Check the time
    func testQuestionTime() {
        do {
            let engine = MLMathMasterEngine()
            engine.newGame(category: .add, type: .sequence, base: [2])
            try engine.qm!.activateNextQuestion()
            let q1 = engine.qm!.currentQuestion!
            
            let expectation = self.expectation(description: "Answer")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.1) {
                do {
                    let _ = try engine.qm!.evaluateQuestion(answer: 3)
                    expectation.fulfill()
                } catch {
                    XCTFail()
                }
            }
            
            waitForExpectations(timeout: 5, handler: nil)
            let timeDifference = q1.totalTime
            XCTAssert( timeDifference >= 3, "Time should be 3 sek or more.. was \(timeDifference)")
        } catch {
            XCTFail()
        }
    }
    
    func testQuestionTimeTotalWithTotalTimeStopOnEvaluateLastQuestion() {
        // StopTime sets when last question is evaluated.
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2], noOfQuestions: 8)
        
        let expectation = self.expectation(description: "Answer")
                
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            do {
                try engine.qm!.activateNextQuestion()
                print("Activated question")
                let q = engine.qm!.currentQuestion
                
                if q != nil {
                    let _ = try engine.qm!.evaluateQuestion(answer: 3)
                } else {
                    timer.invalidate()
                    expectation.fulfill()
                }
            } catch {
                XCTFail()
            }
        }
        
        waitForExpectations(timeout: 30, handler: nil)
        // Because first question get activated and evaluated instantly .. it will take 1 sek less than number of questions
        XCTAssert(round(engine.totalTime) == 7, "TotalTime Should be equal to 7 was \(round(engine.totalTime))")
    }
    
    
}
