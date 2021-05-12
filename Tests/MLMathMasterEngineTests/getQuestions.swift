//
//  File.swift
//
//
//  Created by Michael Lekrans on 2021-05-08.
//

import Foundation
@testable import MLMathMasterEngine
import XCTest

@available(iOS 13.0, *)
final class GetQuestions: XCTestCase {
    // MARK: - Count
    
    // DEFAULT ... should be 10
    // Singles
    func testGetSingleQuestion() throws {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])

        var noOfQuestions = 0
        try engine.qm!.activateNextQuestion()
        while let _ = engine.qm!.currentQuestion {
            noOfQuestions += 1
            let _ = try engine.qm!.evaluateQuestion(answer: 3)
            try engine.qm!.activateNextQuestion()
        }
        
        XCTAssert(noOfQuestions == engine.settings.noOfQuestions, "NoOfQuestions should be \(engine.settings.noOfQuestions), was \(noOfQuestions)")
    }
    
    // Group of 5
    func testGetGroupOfQuestionsSpecifiedByCount5() throws {
        let engine = MLMathMasterEngine()
        engine.newGame(
            category: .add,
            type: .sequence,
            base: [2],
            noOfQuestions: 12,
            groupSize: 5)
                
        // Activate the first 5 questions
        try engine.qm!.activateNextQuestion() // this should fetch 5 questions
        var firstQuestion = engine.qm!.currentQuestions.first!
        print("firstQuestions id when fetched \(firstQuestion.id)")
        print("firstQuestion value = \(firstQuestion.asString())")
        XCTAssertEqual(engine.qm!.currentQuestions.count, 5)
        let _ = try engine.qm!.evaluateQuestion(answer: 3)
        print("evaluating question")
        try (1...4).forEach { i in
            try engine.qm!.activateNextQuestion()
            let _ = try engine.qm!.evaluateQuestion(answer: 3)
            print("evaluating question")
            XCTAssertEqual(firstQuestion, engine.qm!.currentQuestions.first!)
        }
        // Activate next set of 5 questions
        try engine.qm!.activateNextQuestion()
        print("engine first question value\(engine.qm!.currentQuestions.first!.asString()) firstQuestionstring \(firstQuestion.asString())")
        print("engine first question \(engine.qm!.currentQuestions.first!.id) firstQuestionId \(firstQuestion.id)")
        XCTAssertNotEqual(engine.qm!.currentQuestions.first!, firstQuestion)
        firstQuestion = engine.qm!.currentQuestions.first!
        XCTAssertEqual(engine.qm!.currentQuestions.count, 5)
        let _ = try engine.qm!.evaluateQuestion(answer: 3)
        try (1...4).forEach { i in
            try engine.qm!.activateNextQuestion()
            let _ = try engine.qm!.evaluateQuestion(answer: 3)
            XCTAssertEqual(engine.qm!.currentQuestions.first!, firstQuestion)
        }
        
        // Activate next set of 2 questions
        try engine.qm!.activateNextQuestion()
        XCTAssertNotEqual(firstQuestion, engine.qm!.currentQuestions.first!)
        XCTAssertEqual(engine.qm!.currentQuestions.count, 2)
        
    }

    
    // All
    func testGetGroupOfQuestionsSpecifiedByCountDefault() throws {
        // Should return ALL questions
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2], groupSize: -1)
        try engine.qm!.activateNextQuestion()
        XCTAssertEqual(engine.settings.noOfQuestions, engine.qm!.currentQuestions.count)
    }

    // CUSTOM ... should be 12
    // Singles
    func testGetSingleQuestionCustomCount() throws {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2], noOfQuestions: 12, groupSize: -1)

        try engine.qm!.activateNextQuestion()
        XCTAssertEqual(12, engine.qm!.currentQuestions.count)
        XCTAssertEqual(12, engine.qm!.gameData.noOfQuestions)

    }
}
