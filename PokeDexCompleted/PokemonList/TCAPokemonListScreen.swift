//
//  TCAPokemonListScreen.swift
//  PokeDexCompleted
//
//  Created by 小田島 直樹 on 2022/11/09.
//

import ComposableArchitecture
import SwiftUI
import Utilities

struct TCAPokemonListScreen: View {
    let store: StoreOf<PokemonList>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationStack {
                List {
                    ForEach(viewStore.nameList, id: \.self) { name in
                        Text(name)
                    }
                    // 続きがあれば末尾に追加読み込みボタンを配置
                    if viewStore.hasNext {
                        Button {
                            viewStore.send(.loadMoreTapped)
                        } label: {
                            Text(viewStore.isLoading ? "Loading..." : "Load more")
                        }
                        .disabled(viewStore.isLoading)
                        .buttonStyle(.borderless) // Listにタップ領域を奪われないようにする
                        .modifier(CenterModifier()) // Y軸方向に中央表示
                    }
                }
                .navigationTitle("Pokemon List")
            }
            .task {
                viewStore.send(.onAppear)
            }
        }
    }
}

struct TCAPokemonListScreen_Previews: PreviewProvider {
    static var previews: some View {
        TCAPokemonListScreen(
            store: .init(
                initialState: .init(),
                reducer: PokemonList(
                    pokeDexService: MockPokeDexService()
                )
            )
        )
    }
}
