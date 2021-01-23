//
//  DetailViewController.swift
//  GIPHY_SAMPLE
//
//  Created by Paul Jang on 2021/01/15.
//

import UIKit
import RxCocoa
import RxSwift
import ReactorKit
import SDWebImage

class DetailViewController: UIViewController, StoryboardView {
    var disposeBag = DisposeBag()
    var gifObj: GifObject?
    
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var contentImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
        if let obj = gifObj, let url = obj.images?.original?.url {
            contentImageView.sd_setImage(with: URL(string: url)) {[weak self] _, error, _, _ in
                guard let `self` = self else { return }
                guard error == nil else { return }
                
                self.loadIndicator.isHidden = true
            }
        }
    }
    
    func bind(reactor: FavoriteReactor) {
        guard let obj = gifObj else {
            return
        }
        self.favoriteButton.rx.tap
            .map { Reactor.Action.favoriteCheck(obj.id, obj) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
            
        reactor.state.asObservable().map { $0.favoriteState }
            .subscribe(onNext: { [weak self] favoriteState in
                guard let `self` = self else { return }
                
                if favoriteState[obj.id] != nil {
                    self.favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                } else {
                    self.favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
                }
            })
            .disposed(by: self.disposeBag)
    }
}

