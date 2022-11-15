//
//  PokeDexService.swift
//  Utilities
//
//  Created by 小田島 直樹 on 2022/11/15.
//

import PokemonAPI
import RegexBuilder

public protocol PokeDexServiceProtocol {
    func fetchPokemonList(pagination: PokemonListResponse.Pagination?) async throws -> PokemonListResponse
}

public struct PokeDexService: PokeDexServiceProtocol {
    enum Error: Swift.Error {
        case castResultFailed
    }
    
    public init() {}
    
    public func fetchPokemonList(pagination: PokemonListResponse.Pagination?) async throws -> PokemonListResponse {
        let paginationState: PaginationState<PKMPokemon> = pagination?.paginationObject ?? .initial(pageLimit: 20)
        let pagedObject = try await PokemonAPI().pokemonService.fetchPokemonList(paginationState: paginationState)
        guard let resources = pagedObject.results as? [PKMNamedAPIResource<PKMPokemon>] else {
            throw Error.castResultFailed
        }
        let names = resources.compactMap { $0.name }
        return PokemonListResponse(
            pokemonNames: names,
            pagination: pagedObject.hasNext ? .init(paginationObject: PaginationState<PKMPokemon>.continuing(pagedObject, .next)) : nil
        )
    }
}

public struct MockPokeDexService: PokeDexServiceProtocol {
    enum Error: Swift.Error {
        case getNextPageFailed
        case invalidPaginationState
        case castResultFailed
    }
    
    private final class BundleToken {}
    
    public init() {}
    
    public func fetchPokemonList(pagination: PokemonListResponse.Pagination?) async throws -> PokemonListResponse {
        let nextPagedObject: PKMPagedObject<PKMPokemon>
        let nextPagination: PokemonListResponse.Pagination?
        if case let .continuing(pagedObject, relationship) = pagination?.paginationObject {
            guard let pageLink = pagedObject.getPageLink(for: relationship) else {
                throw Error.getNextPageFailed
            }
            let regex = Regex {
                "https://pokeapi.co/api/v2/pokemon?offset="
                TryCapture { OneOrMore(.digit) } transform: { Int($0) }
                "&limit="
                TryCapture { OneOrMore(.digit) } transform: { Int($0) }
            }
            guard let match = pageLink.wholeMatch(of: regex) else {
                throw Error.getNextPageFailed
            }
            let offset = match.1
            let limit = match.2
            let page = offset / limit
            switch page {
            case 1:
                nextPagedObject = try fetchSecondPage()
                nextPagination = .init(paginationObject: .continuing(nextPagedObject, .next))
            case 2:
                nextPagedObject = try fetchLastPage()
                nextPagination = nil
            default:
                throw Error.invalidPaginationState
            }
        } else {
            nextPagedObject = try fetchFirstPage()
            nextPagination = .init(paginationObject: .continuing(nextPagedObject, .next))
        }
        guard let resources = nextPagedObject.results as? [PKMNamedAPIResource<PKMPokemon>] else {
            throw Error.castResultFailed
        }
        let names = resources.compactMap { $0.name }
        try await Task.sleep(for: .seconds(1))
        return PokemonListResponse(
            pokemonNames: names,
            pagination: nextPagination
        )
    }
    
    private func fetchFirstPage<T>() throws -> PKMPagedObject<T> where T: PKMPokemon {
        let data = loadJSON(name: "FetchPokemonListPage1")
        return try PKMPagedObject<T>.decode(from: data)
    }
    
    private func fetchSecondPage<T>() throws -> PKMPagedObject<T> where T: PKMPokemon {
        let data = loadJSON(name: "FetchPokemonListPage2")
        return try PKMPagedObject<T>.decode(from: data)
    }
    
    private func fetchLastPage<T>() throws -> PKMPagedObject<T> where T: PKMPokemon {
        let data = loadJSON(name: "FetchPokemonListPage3")
        return try PKMPagedObject<T>.decode(from: data)
    }
    
    private func loadJSON(name: String) -> Data {
        let bundle = Bundle(for: BundleToken.self)
        guard let urlStr = bundle.path(forResource: name, ofType: "json") else {
            fatalError("\(name).jsonが見つかりません")
        }
        let url = URL(fileURLWithPath: urlStr)
        do {
            return try Data(contentsOf: url)
        } catch {
            fatalError("\(url.absoluteString)を読み込めませんでした")
        }
    }
}
