//
//  DessertListView.swift
//  Desserts
//
//  Created by Desmond Fitch on 6/29/23.
//

import SwiftUI

struct DessertListView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: DessertViewModel
    let meal: Meal
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack {
                    if let imageURL = URL(string: meal.strMealThumb) {
                        AsyncImage(url: imageURL) { image in
                            image.resizable()
                        } placeholder: {
                            Circle()
                                .foregroundColor(.clear)
                        }
                        .frame(width: 300, height: 200)
                        .shadow(radius: 5)
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .padding()
                    }
                    dropdowns
                }
            }
            .navigationTitle(viewModel.mealDetails?.strMeal ?? "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                }
            }
            .onAppear {
                Task {
                    do {
                        let _ = try await viewModel.getDetails(mealID: meal.idMeal)
                    } catch {
                        print("Failed to fetch meal details")
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    var dropdowns: some View {
        VStack(alignment: .leading, spacing: 24) {
            DisclosureGroup(
                content: {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(Array(viewModel.ingredients.sorted(by: { $0.key < $1.key }).enumerated()), id: \.element.key) { index, element in
                            let value = element.value
                            HStack {
                                Text(value.capitalized)
                                if let measurement = viewModel.ingredientsMeasurements["strMeasure\(index + 1)"] {
                                    Text(measurement)
                                        .fontWeight(.bold)
                                } else {
                                    Text("No measurement found")
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical)
                },
                label: {
                    Text("Ingredients")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
            )
            
            DisclosureGroup(
                content: {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(viewModel.instructionsArray(instructions: viewModel.mealDetails?.strInstructions ?? ""), id: \.self) { instruction in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                Text(instruction)
                                    .font(.body)
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(.vertical)
                }, label: {
                    Text("Instructions")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
            )
            Spacer()
        }
        .padding()
        .foregroundColor(.primary)
        .tint(.primary)
    }
}
