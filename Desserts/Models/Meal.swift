//
//  Meal.swift
//  Desserts
//
//  Created by Desmond Fitch on 6/29/23.
//

import Foundation

struct Meal: Codable {
    let strMeal: String
    let strMealThumb: String
    let idMeal: String
}

struct MealDetail: Decodable {
    let idMeal: String
    let strMeal: String
    let strInstructions: String
    let ingredients: [Ingredient]
    let strSource: String?
    let strImageSource: String?
    
    enum CodingKeys: String, CodingKey {
        case idMeal
        case strMeal
        case strInstructions
        case strSource
        case strImageSource
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        idMeal = try values.decode(String.self, forKey: .idMeal)
        strMeal = try values.decode(String.self, forKey: .strMeal)
        strInstructions = try values.decode(String.self, forKey: .strInstructions)
        strSource = try values.decodeIfPresent(String.self, forKey: .strSource)
        strImageSource = try values.decodeIfPresent(String.self, forKey: .strImageSource)
        
        var ingredients: [Ingredient] = []
        for i in 1...20 {
            let ingredientKey = "strIngredient\(i)"
            let measureKey = "strMeasure\(i)"
            if let ingredientKey = CodingKeys(stringValue: ingredientKey),
               let measureKey = CodingKeys(stringValue: measureKey),
               let ingredient = try values.decodeIfPresent(String.self, forKey: ingredientKey),
               let measure = try values.decodeIfPresent(String.self, forKey: measureKey) {
                ingredients.append(Ingredient(name: ingredient, measure: measure))
            }
        }
        self.ingredients = ingredients
    }
}

struct Ingredient: Codable {
    let name: String
    let measure: String
}

struct MealsResponse: Codable {
    let meals: [Meal]
}

struct MealsDetailsResponse: Decodable {
    let meals: [MealDetail]
}

extension Meal {
    var isNotEmpty: Bool {
        return !strMeal.isEmpty || !strMealThumb.isEmpty || !idMeal.isEmpty
    }
}
