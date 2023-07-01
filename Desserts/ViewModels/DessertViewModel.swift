import Foundation
import SwiftUI

class DessertViewModel: ObservableObject {
    @Published var meals = [Meal]()
    @Published var mealDetails: MealDetail?
    @Published var imageURL = URL(string: "")
    @Published var ingredients = [String: String]()
    @Published var ingredientsMeasurements = [String: String]()
    
    enum DessertError: Error {
        case invalidURL
        case invalidResponse
        case invalidData
    }
    
    func loadDesserts() async throws -> [Meal] {
        let endpoint = "https://themealdb.com/api/json/v1/1/filter.php?c=Dessert"
        
        guard let url = URL(string: endpoint) else {
            throw DessertError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw DessertError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            let mealsResponse = try decoder.decode(MealsResponse.self, from: data)
            DispatchQueue.main.async {
                self.meals = mealsResponse.meals.filter { $0.isNotEmpty }
            }
            return mealsResponse.meals
        } catch {
            throw DessertError.invalidData
        }
    }
    
    func getDetails(mealID: String) async throws -> MealDetail {
        let endpoint = "https://themealdb.com/api/json/v1/1/lookup.php?i=\(mealID)"
        
        guard let url = URL(string: endpoint) else {
            throw DessertError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw DessertError.invalidResponse
        }
        
        if let string = String(data: data, encoding: .utf8) {
            let ingredientsAndMeasurements = self.findIngredients(jsonString: string)
            
            let filteredIngredients = self.filterNullEmptyValues(in: ingredientsAndMeasurements[0])
            let filteredMeasurements = self.filterNullEmptyValues(in: ingredientsAndMeasurements[1])
            
            DispatchQueue.main.async {
                self.ingredients = filteredIngredients
                self.ingredientsMeasurements = filteredMeasurements
            }
        } else {
            print("Failed to convert data to string")
        }
        
        do {
            let decoder = JSONDecoder()
            let mealDetail = try decoder.decode(MealsDetailsResponse.self, from: data)
            if let firstMealDetail = mealDetail.meals.first {
                DispatchQueue.main.async {
                    self.mealDetails = firstMealDetail
                    self.imageURL = URL(string: firstMealDetail.strImageSource ?? "")
                }
                return firstMealDetail
            } else {
                throw DessertError.invalidData
            }
        } catch {
            throw DessertError.invalidData
        }
    }
    
    func instructionsArray(instructions: String) -> [String] {
        var steps = instructions.components(separatedBy: ".")
        steps = steps.flatMap { $0.components(separatedBy: "\r\n") }
        steps = steps.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        steps = steps.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        return steps
    }
    
    func findIngredients(jsonString: String) -> [[String: String]] {
        guard let jsonData = jsonString.data(using: .utf8) else {
            return [[:], [:]]
        }
        
        var ingredients = [String: String]()
        var measurements = [String: String]()
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
            if let jsonDict = jsonObject as? [String: Any],
               let meals = jsonDict["meals"] as? [[String: Any]] {
                for meal in meals {
                    for (key, value) in meal {
                        if key.lowercased().contains("ingredient"),
                           let ingredientName = value as? String,
                           !ingredientName.isEmpty {
                            ingredients[key] = ingredientName
                        }
                        if key.lowercased().contains("measure"),
                           let measurementsAmount = value as? String,
                           !measurementsAmount.isEmpty {
                            measurements[key] = measurementsAmount
                        }
                    }
                }
            }
        } catch {
            print("Error: \(error)")
        }
        
        return [ingredients, measurements]
    }
    
    private func filterNullEmptyValues(in dictionary: [String: String]) -> [String: String] {
        return dictionary.filter { !$0.value.isEmpty }
    }
}


enum DessertError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
