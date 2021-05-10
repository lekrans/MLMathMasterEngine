//
//  File.swift
//  
//
//  Created by Michael Lekrans on 2021-05-08.
//

import Foundation

import XCTest
@testable import MLMathMasterEngine

@available(iOS 13.0, *)
final class QuestionsGeneratedTest: XCTestCase {
    
    // MARK: - Have resulttype
    func testEvaluatedQuestionHaveAResultType() {
        do {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])

        var question = engine.getQuestion()!
        try engine.activate(question: question)
        let _ = try engine.evaluateQuestion(question: &question, answer: 2)

        let index = engine.questions.firstIndex { (q) -> Bool in
            q.id == question.id
        }
        XCTAssertNotNil(index)
        XCTAssertNotNil(engine.questions[index!].result)
        } catch {
            XCTFail()
        }
    }

    
    // MARK: - Have 2 values
    func testQuestionsHaveTwoValues() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [1])
        XCTAssertNotNil(engine.questions[0].value1)
        XCTAssertNotNil(engine.questions[0].value2)
    }
    
    // MARK: - Sequence
    func testQuestionGeneratedFromSequenceWithOneAsBase() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [1])
        for i in 0...9 {
            print("testing \(i)")
            XCTAssertTrue(engine.questions[i].value1 == 1 && engine.questions[i].value2 == i, "value1 should be 2 (was \(String(describing: engine.questions[i].value1)), value2 should be \(i) (was \(String(describing: engine.questions[i].value2)))")
        }
    }

    func testQuestionGeneratedFromSequenceWithTwoAsBase() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])
        
        for i in 0...9 {
            print("testing \(i)")
            XCTAssertTrue(engine.questions[i].value1 == 2 && engine.questions[i].value2 == i, "value1 should be 2 (was \(String(describing: engine.questions[i].value1)), value2 should be \(i) (was \(String(describing: engine.questions[i].value2)))")
        }
    }

    func testQuestionGeneratedFromSequenceWithOneAndFourAndSixAsBase() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [1, 4, 6], noOfQuestions: 100)

        var noOfOnes: Int = 0
        var noOfFours: Int = 0
        var noOfSixs: Int = 0
        var otherNumberFound = false

        for i in 0...99 {
            print("testing \(i)")
            let question = engine.questions[i]
            let value1 = question.value1
            let value2 = question.value2
            
            switch value1 {
            case 1:
                noOfOnes += 1
            case 4:
                noOfFours += 1
            case 6:
                noOfSixs += 1
            default:
                otherNumberFound = true
            }

            XCTAssertTrue(value1 == 1 || value1 == 4 || value1 == 6  && engine.questions[i].value2 == i, "value1 should be 1, 4 or 6 (was \(String(value1)), value2 should be \(i) (was \(String(describing: value2)))")
        }
        XCTAssertFalse(otherNumberFound, "otherNumbersFound should be false.. was true")
        XCTAssert(noOfOnes > 0, "NoOfOnes should be greater than 0.. was \(noOfOnes)")
        XCTAssert(noOfFours > 0, "NoOfFours should be greater than 0.. was \(noOfFours)")
        XCTAssert(noOfSixs > 0, "NoOfSixs should be greater than 0.. was \(noOfSixs)")
    }

    
    // MARK: - Random
    // With enum Random default .. should be max 10
    
    func testQuestionGeneratedFromRandomWithOneAsBase() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .random(), base: [1])
        var answerArray: [Int] = Array(repeating: 0, count: 10)
        for i in 0...9 {
            let value2 = engine.questions[i].value2
            answerArray[value2 - 1] += 1
            print("testing \(i)")
            print("value2: \(value2)")
            XCTAssertTrue(engine.questions[i].value1 == 1 && engine.questions[i].value2 <= 10, "value1 should be 1 (was \(String(describing: engine.questions[i].value1)), value2 should be <= 10 (was \(String(describing: engine.questions[i].value2)))")
        }
        XCTAssertTrue(answerArray.contains(where: { $0 > 1 }))
    }

    func testQuestionGeneratedFromRandomWithTwoAsBase() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .random(), base: [2])
        var answerArray: [Int] = Array(repeating: 0, count: 10)
        for i in 0...9 {
            let value2 = engine.questions[i].value2
            answerArray[value2 - 1] += 1
            XCTAssertTrue(engine.questions[i].value1 == 2 && engine.questions[i].value2 <= 10, "value1 should be 2 (was \(String(describing: engine.questions[i].value1)), value2 should <= 10 (was \(String(describing: engine.questions[i].value2)))")
        }
        XCTAssertTrue(answerArray.contains(where: { $0 > 1 }))
    }

    func testQuestionGeneratedFromRandomWithOneAndFourAndSixAsBase() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .random(), base: [1, 4, 6], noOfQuestions: 100)

        var noOfOnes: Int = 0
        var noOfFours: Int = 0
        var noOfSixs: Int = 0
        var otherNumberFound = false
        var answerArray: [Int] = Array(repeating: 0, count: 10)
        for i in 0...99 {
            let value2 = engine.questions[i].value2
            answerArray[value2 - 1] += 1
            let question = engine.questions[i]
            let value1 = question.value1
            
            switch value1 {
            case 1:
                noOfOnes += 1
            case 4:
                noOfFours += 1
            case 6:
                noOfSixs += 1
            default:
                otherNumberFound = true
            }

            XCTAssertTrue(value1 == 1 || value1 == 4 || value1 == 6  && engine.questions[i].value2 <= 10, "value1 should be 1, 4 or 6 (was \(String(value1)), value2 should be <=  10 (was \(String(describing: value2)))")
        }
        XCTAssertFalse(otherNumberFound, "otherNumbersFound should be false.. was true")
        XCTAssert(noOfOnes > 0, "NoOfOnes should be greater than 0.. was \(noOfOnes)")
        XCTAssert(noOfFours > 0, "NoOfFours should be greater than 0.. was \(noOfFours)")
        XCTAssert(noOfSixs > 0, "NoOfSixs should be greater than 0.. was \(noOfSixs)")
    }
    
    // With random(max: specified
    
    func testQuestionGeneratedFromRandomWithOneAsBaseAndRangeLargeThan10() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .random(20), base: [1])
        var answerArray: [Int] = Array(repeating: 0, count: 20)
        var largerThan10 = false
        for i in 0...9 {
            let value2 = engine.questions[i].value2
            largerThan10 = largerThan10 || value2 > 10
            answerArray[value2 - 1] += 1
            XCTAssertTrue(engine.questions[i].value1 == 1 && engine.questions[i].value2 <= 20, "value1 should be 1 (was \(String(describing: engine.questions[i].value1)), value2 should be <= 10 (was \(String(describing: engine.questions[i].value2)))")
        }
        XCTAssertTrue(largerThan10)
    }

    func testQuestionGeneratedFromRandomWithTwoAsBaseAndRangeLargerThan10() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .random(20), base: [2])
        var answerArray: [Int] = Array(repeating: 0, count: 20)
        var largerThan10 = false
        for i in 0...9 {
            let value2 = engine.questions[i].value2
            largerThan10 = largerThan10 || value2 > 10
            answerArray[value2 - 1] += 1
            XCTAssertTrue(engine.questions[i].value1 == 2 && engine.questions[i].value2 <= 20, "value1 should be 2 (was \(String(describing: engine.questions[i].value1)), value2 should <= 10 (was \(String(describing: engine.questions[i].value2)))")
        }
        XCTAssertTrue(largerThan10)
    }

    func testQuestionGeneratedFromRandomWithOneAndFourAndSixAsBaseAndRangeLargerThan10() {
        var largerThan10 = false
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .random(20), base: [1, 4, 6], noOfQuestions: 100)

        var noOfOnes: Int = 0
        var noOfFours: Int = 0
        var noOfSixs: Int = 0
        var otherNumberFound = false
        var answerArray: [Int] = Array(repeating: 0, count: 20)
        for i in 0...99 {
            let value2 = engine.questions[i].value2
            largerThan10 = largerThan10 || value2 > 10
            answerArray[value2 - 1] += 1
            let question = engine.questions[i]
            let value1 = question.value1
            
            switch value1 {
            case 1:
                noOfOnes += 1
            case 4:
                noOfFours += 1
            case 6:
                noOfSixs += 1
            default:
                otherNumberFound = true
            }

            XCTAssertTrue(value1 == 1 || value1 == 4 || value1 == 6  && engine.questions[i].value2 <= 20, "value1 should be 1, 4 or 6 (was \(String(value1)), value2 should be <=  10 (was \(String(describing: value2)))")
        }
        XCTAssertFalse(otherNumberFound, "otherNumbersFound should be false.. was true")
        XCTAssert(noOfOnes > 0, "NoOfOnes should be greater than 0.. was \(noOfOnes)")
        XCTAssert(noOfFours > 0, "NoOfFours should be greater than 0.. was \(noOfFours)")
        XCTAssert(noOfSixs > 0, "NoOfSixs should be greater than 0.. was \(noOfSixs)")
        XCTAssertTrue(largerThan10)
    }
    
    // MARK: - Question asString
    func testQuestionAsStringAdd() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])

        let question = engine.getQuestion()!
            
        XCTAssertEqual(question.asString(), "2 + 0")
    }

    func testQuestionAsStringSubtract() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .subtract, type: .sequence, base: [2])

        let question = engine.getQuestion()!
            
        XCTAssertEqual(question.asString(), "2 - 0")
    }
    
    func testQuestionAsStringMultiply() {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .multiply, type: .sequence, base: [2])

        let question = engine.getQuestion()!
            
        XCTAssertEqual(question.asString(), "2 * 0")
    }

}
