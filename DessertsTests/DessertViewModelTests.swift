//
//  DessertViewModelTests.swift
//  DessertsTests
//
//  Created by Desmond Fitch on 6/30/23.
//

import XCTest
@testable import Desserts

class DessertViewModelTests: XCTestCase {

    var dessertViewModel: DessertViewModel!

    override func setUp() {
        super.setUp()
        dessertViewModel = DessertViewModel()
    }

    override func tearDown() {
        dessertViewModel = nil
        super.tearDown()
    }

    func testLoadDesserts() async throws {
        do {
            let meals = try await dessertViewModel.loadDesserts()
            XCTAssertNotNil(meals)
            XCTAssert(meals.count > 0, "meals array should have at least one meal")
        } catch {
            XCTFail("loadDesserts() method threw an error: \(error)")
        }
    }

    func testGetDetails() async throws {
        do {
            let mealID = "52772"
            let mealDetail = try await dessertViewModel.getDetails(mealID: mealID)
            XCTAssertNotNil(mealDetail)
        } catch {
            XCTFail("getDetails() method threw an error: \(error)")
        }
    }

    func testInstructionsArray() {
        let instructions = "Step 1 Do this.\r\nStep 2 Do that."
        let steps = dessertViewModel.instructionsArray(instructions: instructions)
        
        XCTAssertEqual(steps.count, 2)
        XCTAssertEqual(steps[0], "Step 1 Do this")
        XCTAssertEqual(steps[1], "Step 2 Do that")
    }

    func testFindIngredients() {
        let jsonString = """
        {
            "meals": [{
                "strIngredient1": "Sugar",
                "strIngredient2": "Butter",
                "strMeasure1": "1 cup",
                "strMeasure2": "2 tbsp"
            }]
        }
        """
        let ingredientsAndMeasurements = dessertViewModel.findIngredients(jsonString: jsonString)
        let ingredients = ingredientsAndMeasurements[0]
        let measurements = ingredientsAndMeasurements[1]

        XCTAssertEqual(ingredients["strIngredient1"], "Sugar")
        XCTAssertEqual(ingredients["strIngredient2"], "Butter")
        XCTAssertEqual(measurements["strMeasure1"], "1 cup")
        XCTAssertEqual(measurements["strMeasure2"], "2 tbsp")
    }
}

