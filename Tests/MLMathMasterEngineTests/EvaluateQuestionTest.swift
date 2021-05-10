//
//  File.swift
//  
//
//  Created by Michael Lekrans on 2021-05-08.
//

@testable import MLMathMasterEngine
import XCTest

@available(iOS 13.0, *)
final class EvaluateQuestionTest: XCTestCase {
    
    // add
    func testEvaluateFirstQuestion() throws {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])

        if var question = engine.getQuestion() {
            try engine.activate(question: question)
            let result = try engine.evaluateQuestion(question: &question, answer: 2)!
            XCTAssert(result.success == true , "result.success should be true, was \(result.success)")
            XCTAssertEqual(result.answer, result.expectedAnswer)
        }
    }
    
    func testEvaluateAllQuestionsOnAddAndBase2() throws {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .sequence, base: [2])

        var iteration = 0
        while var question = engine.getQuestion() {
            let answer = iteration + 2
            iteration += 1
            try engine.activate(question: question)
            let result = try engine.evaluateQuestion(question: &question, answer: answer)!
            XCTAssert(result.success == true , "result.success should be true, was \(result.success)")
            XCTAssertEqual(result.answer, result.expectedAnswer)
        }
    }
    
    func testEvaluateAllQuestionsOnAddAndMultipleBaseAndRandom () throws {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .add, type: .random(30), base: [2], noOfQuestions: 100)

        var maxValue = 0
        while var question = engine.getQuestion() {
            maxValue = max(maxValue, question.value2)
            let answer = question.value1 + question.value2
            try engine.activate(question: question)
            let result = try engine.evaluateQuestion(question: &question, answer: answer)!
            XCTAssert(result.success == true , "result.success should be true, was \(result.success)")
            XCTAssertEqual(result.answer, result.expectedAnswer)
        }
        XCTAssert(maxValue > 25, "Max should be higher than 25.. probably.. was \(maxValue)")
    }
    
    // Subtract
    func testEvaluateFirstQuestionSubtract() throws {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .subtract, type: .sequence, base: [2])

        if var question = engine.getQuestion() {
            try engine.activate(question: question)
            let result = try engine.evaluateQuestion(question: &question, answer: 2)!
            XCTAssert(result.success == true , "result.success should be true, was \(result.success)")
            XCTAssertEqual(result.answer, result.expectedAnswer)
        }
    }
    
    
    func testEvaluateAllQuestionsOnAddAndBase2Subtract() throws {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .subtract, type: .sequence, base: [2])

        var iteration = 0
        while var question = engine.getQuestion() {
            let answer = 2 - iteration
            iteration += 1
            try engine.activate(question: question)
            let result = try engine.evaluateQuestion(question: &question, answer: answer)!
            XCTAssert(result.success == true , "result.success should be true, was \(result.success)")
            XCTAssertEqual(result.answer, result.expectedAnswer)
        }
    }
    
    func testEvaluateAllQuestionsOnSubtractAndMultipleBaseAndRandom () throws {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .subtract, type: .random(30), base: [2, 4, 6], noOfQuestions: 100)

        var maxValue = 0
        while var question = engine.getQuestion() {
            maxValue = max(maxValue, question.value2)
            let answer = question.value1 - question.value2
            try engine.activate(question: question)
            let result = try engine.evaluateQuestion(question: &question, answer: answer)!
            XCTAssert(result.success == true , "result.success should be true, was \(result.success)")
            XCTAssertEqual(result.answer, result.expectedAnswer)
        }
        XCTAssert(maxValue > 25, "Max should be higher than 25.. probably.. was \(maxValue)")
    }
    
    // Multiply
    func testEvaluateFirstQuestionMultiply() {
        do {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .multiply, type: .sequence, base: [2, 4, 6])

        if var question = engine.getQuestion() {
            try engine.activate(question: question)
            let result = try engine.evaluateQuestion(question: &question, answer: 0)!
            XCTAssert(result.success == true , "result.success should be true, was \(result.success)")
            XCTAssertEqual(result.answer, result.expectedAnswer)
        }
        } catch {
            XCTFail()
        }
    }
    
    func testEvaluateAllQuestionsOnAddAndBase2Multiply() {
        do {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .multiply, type: .sequence, base: [2])

        var iteration = 0
        while var question = engine.getQuestion() {
            let answer = 2 * iteration
            iteration += 1
            try engine.activate(question: question)
            let result = try engine.evaluateQuestion(question: &question, answer: answer)!
            XCTAssert(result.success == true , "result.success should be true, was \(result.success)")
            XCTAssertEqual(result.answer, result.expectedAnswer)
        }
        } catch {
            XCTFail()
        }
    }
    
    func testEvaluateAllQuestionsOnMultiplyAndMultipleBaseAndRandom () {
        do {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .multiply, type: .random(30), base: [2, 4, 6], noOfQuestions: 100)

        var maxValue = 0
        while var question = engine.getQuestion() {
            maxValue = max(maxValue, question.value2)
            let answer = question.value1 * question.value2
            try engine.activate(question: question)
            let result = try engine.evaluateQuestion(question: &question, answer: answer)!
            XCTAssert(result.success == true , "result.success should be true, was \(result.success)")
            XCTAssertEqual(result.answer, result.expectedAnswer)
        }
        XCTAssert(maxValue > 25, "Max should be higher than 25.. probably.. was \(maxValue)")
        } catch {
            XCTFail()
        }
    }

    // Random
    func testEvaluateFirstQuestionRandom() {
        do {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .random, type: .sequence, base: [2, 4, 6])

        if var question = engine.getQuestion() {
            print(question.asString())
            var answer: Int {
                switch question.category {
                case .add:
                    return question.value1 + question.value2
                case .subtract:
                    return question.value1 - question.value2
                case .multiply:
                    return question.value1 * question.value2
                default:  return -1
                }
            }
            try engine.activate(question: question)
            let result = try engine.evaluateQuestion(question: &question, answer: answer)!
            XCTAssert(result.success == true , "result.success should be true, was \(result.success)")
            XCTAssertEqual(result.answer, result.expectedAnswer)
        }
        } catch {
            XCTFail()
        }
    }
    
    func testEvaluateAllQuestionsOnAddAndBase2Random() {
        do {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .random, type: .sequence, base: [2])


        while var question = engine.getQuestion() {
            print(question.asString())
            var answer: Int {
                switch question.category {
                case .add:
                    return question.value1 + question.value2
                case .subtract:
                    return question.value1 - question.value2
                case .multiply:
                    return question.value1 * question.value2
                default:  return -1
                }
            }
            
            try engine.activate(question: question)
            let result = try engine.evaluateQuestion(question: &question, answer: answer)!
            XCTAssert(result.success == true , "result.success should be true, was \(result.success)")
            XCTAssertEqual(result.answer, result.expectedAnswer)
        }
        } catch {
            XCTFail()
        }
    }
    
    func testEvaluateAllQuestionsOnRandomAndMultipleBaseAndRandom () {
        do {
        let engine = MLMathMasterEngine()
        engine.newGame(category: .random, type: .random(30), base: [2, 4, 6], noOfQuestions: 100)

        var maxValue = 0
        while var question = engine.getQuestion() {
            maxValue = max(maxValue, question.value2)
            print(question.asString())
            var answer: Int {
                switch question.category {
                case .add:
                    return question.value1 + question.value2
                case .subtract:
                    return question.value1 - question.value2
                case .multiply:
                    return question.value1 * question.value2
                default:  return -1
                }
            }
            
            try engine.activate(question: question)
            let result = try engine.evaluateQuestion(question: &question, answer: answer)!
            XCTAssert(result.success == true , "result.success should be true, was \(result.success)")
            XCTAssertEqual(result.answer, result.expectedAnswer)
        }
        XCTAssert(maxValue > 25, "Max should be higher than 25.. probably.. was \(maxValue)")
        } catch {
            XCTFail()
        }
    }
}
