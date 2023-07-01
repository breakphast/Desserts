//
//  ContentView.swift
//  Desserts
//
//  Created by Desmond Fitch on 6/29/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: DessertViewModel
    
    var body: some View {
        TabView {
            NavigationView {
                VStack(alignment: .leading) {
                    ScrollView(showsIndicators: false) {
                        ForEach(viewModel.meals, id: \.idMeal) { meal in
                            NavigationLink(destination: DessertListView(meal: meal)) {
                                MealRow(meal: meal)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .navigationTitle("Desserts")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    viewModel.mealDetails = nil
                }
                .task {
                    do {
                        _ = try await viewModel.loadDesserts()
                    } catch {
                        print("Error: \(error)")
                    }
                }
            }
            .tabItem {
                Label("Desserts", systemImage: "square.stack")
                    .accentColor(.black)
            }
            
            Text("")
                .tabItem {
                    Label("Saved", systemImage: "heart.fill")
                        .accentColor(.black)
                }
        }
        .accentColor(.black)
    }
}

struct MealRow: View {
    let meal: Meal
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center, spacing: 12) {
                if let imageURL = URL(string: meal.strMealThumb) {
                    AsyncImage(url: imageURL) { image in
                        image.resizable()
                    } placeholder: {
                        Circle()
                            .foregroundColor(.clear)
                    }
                    .frame(width: 60, height: 60)
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(.black, lineWidth: 1)
                    )
                }
                Text(meal.strMeal)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            Divider()
        }
        .padding(.horizontal)
    }
}
