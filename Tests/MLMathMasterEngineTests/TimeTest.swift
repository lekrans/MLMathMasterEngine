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
        let question = engine.getQuestion()! // remember that it is valueType
        XCTAssert(question.startTime == nil, "StartTime should be nil")
        try engine.activate(question: question)
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
        var question = engine.getQuestion()! // remember that it is valueType
        try engine.activate(question: question)
        XCTAssert(question.startTime != nil, "StartTime should NOT be nil")
        XCTAssert(question.stopTime == nil, "StartTime should be nil")
        let _ = try engine.evaluateQuestion(question: &question, answer: 23)
        XCTAssert(question.startTime != nil, "StartTime should have a value, was nil")
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
        var q1 = engine.getQuestion()!
        try engine.activate(question: q1)
        
        let expectation = self.expectation(description: "Answer")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.1) {
            do {
            let _ = try engine.evaluateQuestion(question: &q1, answer: 3)
            expectation.fulfill()
            } catch {
                XCTFail()
            }
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        let timeDifference = q1.totalTime
        print("timeDifference = \(timeDifference)")
        XCTAssert( timeDifference >= 3, "Time should be 3 sek or more.. was \(timeDifference)")
        } catch {
            XCTFail()
        }
    }
    
    func testQuestionTimeTotalWithTotalTimeStopOnEvaluateLastQuestion() {
        // stopTime should be set when we call getQuestion last time and get nil back
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])

        let expectation = self.expectation(description: "Answer")
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            do {
            let q = engine.getQuestion()
            
            if var q = q {
                try engine.activate(question: q)
                let _ = try engine.evaluateQuestion(question: &q, answer: 3)
            } else {
                timer.invalidate()
                expectation.fulfill()
            }
            } catch {
                XCTFail()
            }
        }
        
        waitForExpectations(timeout: 12, handler: nil)
        
        XCTAssert(engine.totalTime > 9, "TotalTime Should be greater than 9 was \(engine.totalTime)")
    }
    
    func testQuestionTotalTimeAfterExplicitStopGame() throws {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])
        
        let questions = try engine.getQuestions()!
        var nextQuestion = 0
        
        let expectation = self.expectation(description: "Answer")
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            do {
                if nextQuestion < questions.count {
                    var question = questions[nextQuestion]
                    try engine.activate(question: question)
                    let _ = try engine.evaluateQuestion(question: &question, answer: 3)
                    nextQuestion += 1
                } else {
                    engine.stopGame()
                    timer.invalidate()
                    expectation.fulfill()
                }
            } catch {
                XCTFail()
            }
        }

        waitForExpectations(timeout: 12, handler: nil)
        
        XCTAssert(engine.totalTime > 9, "TotalTime Should be greate than 9 was \(engine.totalTime)")

    }
        
}
