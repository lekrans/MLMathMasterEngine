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
    func testGetSingleQuestion() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])

        var noOfQuestions = 0
        while let _ = engine.getQuestion() {
            noOfQuestions += 1
        }
        
        XCTAssert(noOfQuestions == engine.settings.noOfQuestions, "NoOfQuestions should be \(engine.settings.noOfQuestions), was \(noOfQuestions)")
    }
    
    // Group of 5
    func testGetGroupOfQuestionsSpecifiedByCount5() throws {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])
        
        var noOfQuestions = 0
        var noOfIterations = 0
        var noOfQuestionsLastTime = 0
        while let questions = try engine.getQuestions(by: 5) {
            noOfQuestionsLastTime = questions.count == 5 ? 0 : questions.count
            noOfIterations += 1
            questions.forEach { _ in
                noOfQuestions += 1
            }
        }
        XCTAssert(noOfQuestions == engine.settings.noOfQuestions, "NoOfQuestions should be \(engine.settings.noOfQuestions) was \(noOfQuestions)")
        
        var expectedIterations = engine.settings.noOfQuestions / 5
        if engine.settings.noOfQuestions % 5 > 0 {
            expectedIterations += 1
        }
        XCTAssert(noOfIterations == expectedIterations, "NoOfIterations should be  \(expectedIterations) was \(noOfIterations)")
        XCTAssert(noOfQuestionsLastTime == engine.settings.noOfQuestions % 5, "NoOfQuestionsLastTime should be \(engine.settings.noOfQuestions % 5), was \(noOfQuestionsLastTime)")
    }

    
    // All
    func testGetGroupOfQuestionsSpecifiedByCountDefault() throws {
        // Should return ALL questions
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])
        
        let questions = try engine.getQuestions()!
        XCTAssert(questions.count == engine.settings.noOfQuestions, "questions count should be \(engine.settings.noOfQuestions), was \(questions.count)")
    }

    // CUSTOM ... should be 12
    // Singles
    func testGetSingleQuestionCustomCount() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2], noOfQuestions: 12)

        var noOfQuestions = 0
        while let _ = engine.getQuestion() {
            noOfQuestions += 1
        }
        
        XCTAssert(noOfQuestions == 12, "NoOfQuestions should be 12, was \(noOfQuestions)")
    }
    
    // Group of 5
    func testGetGroupOfQuestionsSpecifiedByCount5CustomCount() throws {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2], noOfQuestions: 12)
        
        var noOfQuestions = 0
        var noOfIterations = 0
        var noOfQuestionsLastTime = 0
        while let questions = try engine.getQuestions(by: 5) {
            noOfQuestionsLastTime = questions.count == 5 ? 0  : questions.count
            noOfIterations += 1
            questions.forEach { _ in
                noOfQuestions += 1
            }
        }
        XCTAssert(noOfQuestions == 12, "NoOfQuestions should be \(12) was \(noOfQuestions)")
        
        var expectedIterations = 12 / 5
        if 12 % 5 > 0 {
            expectedIterations += 1
        }
        XCTAssert(noOfIterations == expectedIterations, "NoOfIterations should be  \(expectedIterations) was \(noOfIterations)")
        XCTAssert(noOfQuestionsLastTime == 12 % 5, "NoOfQuestionsLastTime should be \(12 % 5), was \(noOfQuestionsLastTime)")
    }

    
    // All
    func testGetGroupOfQuestionsSpecifiedByCountDefaultCustomCount() throws {
        // Should return ALL questions
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2], noOfQuestions: 12)
        
        let questions = try engine.getQuestions()!
        XCTAssert(questions.count == 12, "questions count should be 12, was \(questions.count)")
    }
    
    // MARK: - TimeAttack
    func testGetSingleQuestionTimeAttack() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .random, max: 100, base: [2,3,4], timeAttackTime: .oneMin)
        
        let q = engine.getQuestion()
        XCTAssertNotNil(q)
        XCTAssertEqual(engine.questions.count, 1)
    }
    
    func testGetGroupOfQuestionsSpecifiedByCount5CustomCountOnTimeAttackShouldFail() throws {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .random, max: 100, base: [2,3,4], timeAttackTime: .oneMin)
        
        XCTAssertThrowsError(try engine.getQuestions(by: 5))
        
    }

    func testGetGroupOfQuestionsGetAllOnTimeAttackShouldFail() throws {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .random, max: 100, base: [2,3,4], timeAttackTime: .oneMin)
        
        XCTAssertThrowsError(try engine.getQuestions())
        
    }

    
}
