//
//  PokemonListScreen.swift
//  PokeDexCompleted
//
//  Created by 小田島 直樹 on 2022/11/16.
//

import SwiftUI
import Utilities

struct PokemonListScreen: View {
    /// APIを提供するクラス
    let pokeDexService: PokeDexServiceProtocol
    /// ポケモン名のリスト
    @State private var nameList: [String] = []
    /// ページングの情報. このオブジェクトでリストの続きを取得する
    @State private var pagination: PokemonListResponse.Pagination?
    /// ローディング中かどうか
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(nameList, id: \.self) { name in
                    Text(name)
                }
                // ページネーションに続きがあれば末尾に追加読み込みボタンを配置
                if let pagination {
                    Button {
                        Task {
                            isLoading = true
                            defer { isLoading = false }
                            let response = try await pokeDexService.fetchPokemonList(pagination: pagination)
                            nameList += response.pokemonNames
                            self.pagination = response.pagination
                        }
                    } label: {
                        Text(isLoading ? "Loading..." : "Load more")
                    }
                    .disabled(isLoading)
                    .buttonStyle(.borderless) // Listにタップ領域を奪われないようにする
                    .modifier(CenterModifier()) // Y軸方向に中央表示
                }
            }
            .navigationTitle("Pokemon List")
        }
        .task {
            do {
                isLoading = true
                defer { isLoading = false }
                let response = try await pokeDexService.fetchPokemonList(pagination: nil)
                nameList += response.pokemonNames
                pagination = response.pagination
            } catch {}
        }
    }
}

struct PokemonListScreen_Previews: PreviewProvider {
    static var previews: some View {
        PokemonListScreen(
            pokeDexService: MockPokeDexService()
        )
    }
}
