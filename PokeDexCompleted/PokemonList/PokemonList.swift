//
//  PokemonList.swift
//  PokeDexCompleted
//
//  Created by 小田島 直樹 on 2022/11/15.
//

import ComposableArchitecture
import Utilities

struct PokemonList: ReducerProtocol {
    let pokeDexService: PokeDexServiceProtocol
    
    struct State: Equatable {
        var nameList: [String] = []
        var isLoading: Bool = false
        var hasNext: Bool {
            pagination != nil
        }
        fileprivate var pagination: PokemonListResponse.Pagination? = nil
    }
    
    enum Action: Equatable {        
        /// 画面が表示された時
        case onAppear
        /// Load moreボタンを押した時
        case loadMoreTapped
        /// APIのレスポンスを得た時
        case loadNextResponse(TaskResult<PokemonListResponse>)
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        // 画面が表示されたら、APIでリストの初めを取得
        case .onAppear:
            state.isLoading = true
            return .task {
                let result = await TaskResult {
                    try await pokeDexService.fetchPokemonList(pagination: nil)
                }
                return .loadNextResponse(result)
            }
        // Load moreボタンを押したら、APIでリストの続きを取得
        case .loadMoreTapped:
            guard let pagination = state.pagination else {
                return .none
            }
            state.isLoading = true
            return .task {
                let result = await TaskResult {
                    try await pokeDexService.fetchPokemonList(pagination: pagination)
                }
                return .loadNextResponse(result)
            }
        // APIのレスポンスが返ってきたら、リストを更新
        case let .loadNextResponse(result):
            state.isLoading = false
            guard let response = try? result.value else {
                return .none
            }
            state.nameList += response.pokemonNames
            state.pagination = response.pagination
            return .none
        }
    }
}
