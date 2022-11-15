//
//  PokeDexCompletedApp.swift
//  PokeDexCompleted
//
//  Created by 小田島 直樹 on 2022/11/09.
//

import SwiftUI
import Utilities

@main
struct PokeDexCompletedApp: App {
    var body: some Scene {
        WindowGroup {
//            PokemonListScreen(pokeDexService: PokeDexService())
            TCAPokemonListScreen(
                store: .init(
                    initialState: .init(),
                    reducer: PokemonList(
                        pokeDexService: PokeDexService()
                    )
                )
            )
        }
    }
}
