//
//  PokemonAPIExtensions.swift
//  Utilities
//
//  Created by 小田島 直樹 on 2022/11/15.
//

import PokemonAPI

extension PKMPagedObject<PKMPokemon>: Equatable {
    public static func == (
        lhs: PKMPagedObject<PKMPokemon>,
        rhs: PKMPagedObject<PKMPokemon>
    ) -> Bool {
        lhs.hasNext == rhs.hasNext
        && lhs.hasPrevious == rhs.hasPrevious
        && lhs.current == rhs.current
        && lhs.currentPage == rhs.currentPage
        && lhs.results == rhs.results
    }
}

extension PKMAPIResource<PKMPokemon>: Equatable {
    public static func == (
        lhs: PKMAPIResource<PKMPokemon>,
        rhs: PKMAPIResource<PKMPokemon>
    ) -> Bool {
        lhs.url == rhs.url
    }
}

extension PaginationState<PKMPokemon>: Equatable {
    public static func == (
        lhs: PaginationState<PKMPokemon>,
        rhs: PaginationState<PKMPokemon>
    ) -> Bool {
        switch (lhs, rhs) {
        case (let .initial(lPageLimit), let .initial(rPageLimit)):
            return lPageLimit == rPageLimit
        case (let .continuing(lPagedObject, lRelationship), let .continuing(rPagedObject, rRelationship)):
            return lPagedObject == rPagedObject && lRelationship == rRelationship
        default:
            return false
        }
    }
}

extension PaginationRelationship: Equatable {
    public static func == (
        lhs: PaginationRelationship,
        rhs: PaginationRelationship
    ) -> Bool {
        switch (lhs, rhs) {
        case (let .page(lPage), let .page(rPage)):
            return lPage == rPage
        case (.first, .first), (.last, .last), (.next, .next), (.previous, .previous):
            return true
        default:
            return false
        }
    }
}
