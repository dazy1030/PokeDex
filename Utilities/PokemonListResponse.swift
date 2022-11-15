//
//  PokemonListResponse.swift
//  Utilities
//
//  Created by 小田島 直樹 on 2022/11/16.
//

import PokemonAPI

public struct PokemonListResponse: Equatable {
    public let pokemonNames: [String]
    public let pagination: Pagination?
}

extension PokemonListResponse {
    public struct Pagination: Equatable {
        let paginationObject: PaginationState<PKMPokemon>
    }
}
