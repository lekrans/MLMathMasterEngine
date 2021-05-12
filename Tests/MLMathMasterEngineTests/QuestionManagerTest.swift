//
//  File.swift
//  
//
//  Created by Michael Lekrans on 2021-05-11.
//

import Foundation
import XCTest
@testable import MLMathMasterEngine

@available(iOS 13.0, *)

final class QuestionManagerTest: XCTestCase {
    
    // MARK: - API
    
        // createNewQuestionSet()
    func testCreateNewQuestionSetInternalProperties() {
        let gameData = MLMathMasterGameData(category: .subtract, type: .sequence, base: [2], timeAttackTime: .none, groupSize: 5, noOfQuestions: -1)
        let qm = MLMathMasterGameQuestionManager(gameData: gameData)
        XCTAssertEqual(qm.gameData.noOfQuestions, -1)
        XCTAssertEqual(qm.gameData.groupSize, 5)
        XCTAssertEqual(qm.gameData.type, .sequence)
        XCTAssertEqual(qm.gameData.category, .subtract)
        XCTAssertEqual(qm.gameData.base, [2])
        
        // TODO: Add tests on internal properties that they are reset
    }
    
    func test_activateNextQuestionNoLimitNoGroup() throws {
        let gameData = MLMathMasterGameData(category: .subtract, type: .sequence, base: [2], timeAttackTime: .none, groupSize: 1, noOfQuestions: -1)
        let qm = MLMathMasterGameQuestionManager(gameData: gameData)

        try qm.activateNextQuestion()
        XCTAssertNotNil(qm.currentQuestion)
        XCTAssertNotEqual(qm.currentQuestions, [])
        XCTAssertEqual(qm.currentQuestions.count, 1)
        XCTAssertTrue(qm.currentQuestions[0].active == true)
        XCTAssertEqual(qm.currentQuestion, qm.currentQuestions[0])

    }

    func test_activateNextQuestionNoLimitGroup5() throws {
        let gameData = MLMathMasterGameData(category: .subtract, type: .sequence, base: [2], timeAttackTime: .none, groupSize: 5, noOfQuestions: -1)
        let qm = MLMathMasterGameQuestionManager(gameData: gameData)

        try qm.activateNextQuestion()
        XCTAssertNotNil(qm.currentQuestion)
        XCTAssertNotEqual(qm.currentQuestions, [])
        XCTAssertEqual(qm.currentQuestions.count, 5)
        XCTAssertTrue(qm.currentQuestions[0].active == true)
        XCTAssertEqual(qm.currentQuestion, qm.currentQuestions[0])
    }

    
    func test_activateNextQuestion3timesNoLimitGroup5() throws {
        let gameData = MLMathMasterGameData(category: .subtract, type: .sequence, base: [2], timeAttackTime: .none, groupSize: 5, noOfQuestions: -1)
        let qm = MLMathMasterGameQuestionManager(gameData: gameData)
        
        try qm.activateNextQuestion()
        let _ = try qm.evaluateQuestion(answer: 3)
        try qm.activateNextQuestion()
        let _ = try qm.evaluateQuestion(answer: 3)
        try qm.activateNextQuestion()
        let _ = try qm.evaluateQuestion(answer: 3)

        XCTAssertNotNil(qm.currentQuestion)
        XCTAssertNotEqual(qm.currentQuestions, [])
        XCTAssertEqual(qm.currentQuestions.count, 5)
        XCTAssertTrue(qm.currentQuestions[2].active == true)
        XCTAssertEqual(qm.currentQuestion, qm.currentQuestions[2])
        XCTAssertNotEqual(qm.currentQuestion, qm.currentQuestions[1])
    }

}

