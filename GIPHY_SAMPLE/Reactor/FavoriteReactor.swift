//
//  FavoriteReactor.swift
//  GIPHY_SAMPLE
//
//  Created by Paul Jang on 2021/01/15.
//

import Foundation
import ReactorKit
import RxCocoa
import RxSwift

class FavoriteReactor: Reactor {
    let initialState: State
    
    enum Action {
        case favoriteCheck(String, GifObject)
        case favoriteViewing
    }
    
    enum Mutation {
        case editFavoriteState(String, GifObject?)
        case getFavoriteData([String : GifObject]?)
    }
    
    struct State {
        var favoriteState = [String : GifObject]()
        var favoriteKeyArr = [String]()
    }
    
    init() {
        if let dict = UserDefaultsService.value(forKey: "FavoriteState") {
            self.initialState = State(favoriteState: dict, favoriteKeyArr: Array(dict.keys))
        } else {
            self.initialState = State(favoriteState: [String : GifObject](), favoriteKeyArr: [])
        }
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            case let .favoriteCheck(id, obj):
                var gifObj: GifObject? = obj
                var state = currentState.favoriteState
                if state[id] != nil { //값이 있다면,
                    state[id] = nil
                    gifObj = nil
                } else {
                    state[id] = gifObj
                }
                
                return UserDefaultsService.set(value: state, forKey: "FavoriteState").map { Mutation.editFavoriteState(id, gifObj) }
            case .favoriteViewing:
                return UserDefaultsService.value(forKey: "FavoriteState").map { Mutation.getFavoriteData($0) }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
            case let .editFavoriteState(id, obj):
                newState.favoriteState[id] = obj
                newState.favoriteKeyArr = Array(newState.favoriteState.keys)
                break
            case let .getFavoriteData(data):
                newState.favoriteState = data ?? [String : GifObject]()
                newState.favoriteKeyArr = Array(newState.favoriteState.keys)
        }
        return newState
    }
     
}
 
