//
//  FavoriteViewController.swift
//  GIPHY_SAMPLE
//
//  Created by Paul Jang on 2021/01/17.
//

import UIKit
import RxCocoa
import RxSwift
import RxViewController
import ReactorKit
import SDWebImage

class FavoriteViewController: UIViewController, StoryboardView {
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var gifCollectionView: UICollectionView!
 
     override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reactor = FavoriteReactor()
        setupUI()
    }
     
    func setupUI() {        
        if let layout = gifCollectionView.collectionViewLayout as? DynamicLayout {
            layout.delegate = self
        }
    }
     
    func bind(reactor: FavoriteReactor) {
        reactor.state.map { $0.favoriteState }.bind(to: gifCollectionView.rx.items(cellIdentifier: String(describing: GifCollectionViewCell.self), cellType: GifCollectionViewCell.self)) { index, data, cell in
            
            if let images = data.value.images, let url = images.thumbnail?.url {
                cell.contentImageView.sd_setImage(with: URL(string: url))
            }
            
        }.disposed(by: disposeBag)
         
        gifCollectionView.rx.itemSelected.subscribe(onNext: { [weak self, weak reactor] indexPath in
            guard let `self` = self else { return }
            
            guard reactor?.currentState.favoriteKeyArr.count ?? 0 > indexPath.row else { return }
            guard let key = reactor?.currentState.favoriteKeyArr[indexPath.row] else { return }
            guard let gifObj = reactor?.currentState.favoriteState[key] else { return }
            
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {

                vc.gifObj = gifObj
                vc.reactor = self.reactor
                self.navigationController?.pushViewController(vc, animated: true)

            }
        }).disposed(by: disposeBag)
        
        self.rx.viewWillAppear.map { _ in Reactor.Action.favoriteViewing }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
    }
}
  
extension FavoriteViewController: UICollectionViewDelegateFlowLayout, DynamicLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath, width: CGFloat) -> CGFloat {
        guard let reactor = reactor else { return 0 }
        guard reactor.currentState.favoriteKeyArr.count > indexPath.row else { return 0 }
      
        let key = reactor.currentState.favoriteKeyArr[indexPath.row]
        
        if let obj = reactor.currentState.favoriteState[key] {
            if let strHeight = obj.images?.thumbnail?.height, let _height = Float(strHeight),
               let strWidth = obj.images?.thumbnail?.width, let _width = Float(strWidth){
                return CGFloat(_height) * CGFloat(width) / CGFloat(_width)
            }
        }

        return 0
    }     
}
