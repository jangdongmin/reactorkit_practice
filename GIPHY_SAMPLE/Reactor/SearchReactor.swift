//
//  SearchReactor.swift
//  GIPHY_SAMPLE
//
//  Created by Paul Jang on 2021/01/12.
//

import Foundation

import ReactorKit
import RxCocoa
import RxSwift


enum ItemType {
    case GIF
    case STICKER
}

class SearchReactor: Reactor {
    let initialState = State()
    
    enum Action {
        case searchKeyword(String)
        case requestNextPage
        case searchItemTypeChange(ItemType)
    }
    
    enum Mutation {
        case setKeyword(String)
        case setGifObj([GifObject], nextPage: Int?)
        case appendGifObj([GifObject], nextPage: Int?)
        case setIsDataLoading(Bool)
        case setSearchItemType(ItemType)
    }
    
    struct State {
        var keyword = ""
        var searchType = ItemType.GIF
        
        var gifObjs: [GifObject] = []
        var isDataLoading: Bool = false
        var LoadingViewIsHidden: Bool = true
        var nextPage: Int?        
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            case let .searchKeyword(keyword):
                guard keyword != "" else {
                    return Observable.concat([
                        Observable.just(Mutation.setKeyword("")),
                        Observable.just(Mutation.setGifObj([], nextPage: 0))
                    ])}
                 
                //print("searchKeyword = ", keyword, " self.currentState.searchType = ", self.currentState.searchType)
                
                return Observable.concat([
                    Observable.just(Mutation.setIsDataLoading(true)),
                    Observable.just(Mutation.setKeyword(keyword)),
                    APIService.searchGIF(keyword: keyword, page: 0, itemType: self.currentState.searchType)
                        .map {Mutation.setGifObj($0, nextPage: $1)},
                    Observable.just(Mutation.setIsDataLoading(false)).delay(.seconds(2), scheduler: MainScheduler.instance)
                ])
            case .requestNextPage:
                guard !(self.currentState.isDataLoading) else { return Observable.empty() }
                guard self.currentState.keyword != "" else { return Observable.empty() }
                guard let page = self.currentState.nextPage else { return Observable.empty() }
                
//                print("self.currentState.isDataLoading = ", self.currentState.isDataLoading)
//                print("requestNextPage = ", self.currentState.keyword, " page = ", page)
                
                return Observable.concat([
                    Observable.just(Mutation.setIsDataLoading(true)),
                    APIService.searchGIF(keyword: self.currentState.keyword, page: page, itemType: self.currentState.searchType).catchErrorJustReturn(([], 0))
                        .map {Mutation.appendGifObj($0, nextPage: $1)},
                    Observable.just(Mutation.setIsDataLoading(false))
                ])
            case let .searchItemTypeChange(itemType):
                if self.currentState.keyword != "" {
                    
                    var searchItemTypeObs: Observable<SearchReactor.Mutation>?
                    if itemType == ItemType.GIF {
                        searchItemTypeObs =  Observable.just(Mutation.setSearchItemType(ItemType.GIF))
                    } else {
                        searchItemTypeObs =  Observable.just(Mutation.setSearchItemType(ItemType.STICKER))
                    }
                    
                    guard let searchItemTypeObservable = searchItemTypeObs else { return Observable.empty() }
                    
                    return Observable.concat([
                        Observable.just(Mutation.setIsDataLoading(true)),
                        APIService.searchGIF(keyword: self.currentState.keyword, page: 0, itemType: itemType).catchErrorJustReturn(([], 0))
                            .map {Mutation.setGifObj($0, nextPage: $1)},
                        Observable.just(Mutation.setIsDataLoading(false)),
                        searchItemTypeObservable
                    ])
                } else {
                    if itemType == ItemType.GIF {
                        return Observable.just(Mutation.setSearchItemType(ItemType.GIF))
                    } else {
                        return Observable.just(Mutation.setSearchItemType(ItemType.STICKER))
                    }
                }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
            case let .setGifObj(obj, nextPage):
                newState.gifObjs = obj
                newState.nextPage = nextPage                
            case let .setKeyword(keyword):
                newState.keyword = keyword
            case let .setIsDataLoading(isLoading):
                newState.isDataLoading = isLoading
                newState.LoadingViewIsHidden = !isLoading
            case let .appendGifObj(obj, nextPage):
                newState.gifObjs.append(contentsOf: obj)
                newState.nextPage = nextPage
            case let .setSearchItemType(type):
                newState.searchType = type
                newState.nextPage = 0
        }
        return newState
    }     
}
 
