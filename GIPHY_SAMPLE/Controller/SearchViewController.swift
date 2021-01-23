//
//  SearchViewController.swift
//  GIPHY_SAMPLE
//
//  Created by Paul Jang on 2021/01/12.
//

import UIKit
import RxCocoa
import RxSwift
import ReactorKit
import SDWebImage
import RxGesture 

class SearchViewController: UIViewController, StoryboardView {
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    @IBOutlet weak var gifCollectionView: UICollectionView!
    
    @IBOutlet weak var typeBackground: UIView!
    @IBOutlet weak var gifTypeView: UIView!
    @IBOutlet weak var stickerTypeView: UIView!
    
    @IBOutlet weak var gifsLabel: UILabel!
    @IBOutlet weak var stickersLabel: UILabel!
    
    var selectView = UIView()
    
    private let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "GIF 검색"
        return searchController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reactor = SearchReactor()
        
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.setupUI()
        }
    }
    
    func setupUI() {
        initSearchBarSetting()
        initTypeView()
        
        if let layout = gifCollectionView.collectionViewLayout as? DynamicLayout {
            layout.delegate = self
        }        
    }
    
    func initSearchBarSetting() {
        searchController.searchBar.setValue("취소", forKey:"cancelButtonText")
        searchController.obscuresBackgroundDuringPresentation = false

        navigationItem.searchController = searchController
        navigationItem.title = "검색"
        navigationItem.hidesSearchBarWhenScrolling = false
        
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func initTypeView() {
        gifsTypeSelect(animation: false)
        
        selectView.layer.cornerRadius = 15
        selectView.backgroundColor = .systemPink
        typeBackground.addSubview(selectView)
    }
    
    func gifsTypeSelect(animation: Bool) {
        let margin: CGFloat = 10
        
        if animation {
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let `self` = self else { return }
                
                self.selectView.backgroundColor = .systemPink
                self.selectView.frame = CGRect(x: self.gifsLabel.frame.origin.x - (margin * 2), y: self.gifsLabel.frame.origin.y - margin,
                                               width: self.gifsLabel.frame.size.width + (margin * 4), height: self.gifsLabel.frame.size.height + (margin * 2))
            }
            return
        }
        
        selectView.frame = CGRect(x: gifsLabel.frame.origin.x - (margin * 2), y: gifsLabel.frame.origin.y - margin,
                                       width: gifsLabel.frame.size.width + (margin * 4), height: gifsLabel.frame.size.height + (margin * 2))
    }
    
    func stickerTypeSelect(animation: Bool) {
        let margin: CGFloat = 10
        
        if animation {
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let `self` = self else { return }
                
                self.selectView.backgroundColor = .systemBlue
                self.selectView.frame = CGRect(x: self.stickerTypeView.frame.origin.x + self.stickersLabel.frame.origin.x - (margin * 2), y: self.stickersLabel.frame.origin.y - margin,
                                               width: self.stickersLabel.frame.size.width + (margin * 4), height: self.stickersLabel.frame.size.height + (margin * 2))
            }
            return
        }
        
        selectView.frame = CGRect(x: stickersLabel.frame.origin.x - (margin * 2), y: stickersLabel.frame.origin.y - margin,
                                  width: stickersLabel.frame.size.width + (margin * 4), height: stickersLabel.frame.size.height + (margin * 2))
    }
     
    func bind(reactor: SearchReactor) {
        searchController.searchBar.rx.cancelButtonClicked
            .map { Reactor.Action.searchKeyword("") }
            .bind(to: reactor.action).disposed(by: disposeBag)
        
        searchController.searchBar.rx.text.orEmpty
                        .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
                        .distinctUntilChanged()
                        .map { Reactor.Action.searchKeyword($0) }
                        .map { [weak self] in
                            guard let `self` = self else { return $0 }
                            self.gifCollectionView.contentOffset = CGPoint(x: 0, y: 0)
                            return $0
                        }
                        .bind(to: reactor.action)
                        .disposed(by: disposeBag)
          
        reactor.state.map { $0.gifObjs }.bind(to: gifCollectionView.rx.items(cellIdentifier: String(describing: GifCollectionViewCell.self), cellType: GifCollectionViewCell.self)) { index, gifObj, cell in
            
            if let images = gifObj.images, let url = images.thumbnail?.url {
                cell.contentImageView.sd_setImage(with: URL(string: url))
            }

        }.disposed(by: disposeBag)

        reactor.state.map { $0.LoadingViewIsHidden }.bind(to: loadIndicator.rx.isHidden).disposed(by: disposeBag)
         
        gifCollectionView.rx.itemSelected.subscribe(onNext: { [weak self, weak reactor] indexPath in
            guard let `self` = self else { return }
            guard reactor?.currentState.gifObjs.count ?? 0 > indexPath.row else { return }
            guard let gifObj = reactor?.currentState.gifObjs[indexPath.row] else { return }

            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {

                vc.gifObj = gifObj
                vc.reactor = FavoriteReactor()
                self.navigationController?.pushViewController(vc, animated: true)

            }
        }).disposed(by: disposeBag)
        
        gifCollectionView.rx.contentOffset.filter { [weak self] offset in
            guard let `self` = self else { return false }
            guard self.gifCollectionView.frame.height > 0 else { return false }            
            return offset.y + self.gifCollectionView.frame.height >= self.gifCollectionView.contentSize.height - 200
        }
        .map { _ in Reactor.Action.requestNextPage }
        .bind(to: reactor.action)
        .disposed(by: disposeBag)
         
        
        reactor.state.map { $0.searchType }.distinctUntilChanged().subscribe { [weak self, weak reactor] _ in
            guard let `self` = self else { return }
            guard let reactor = reactor else { return }
            
            if reactor.currentState.searchType == ItemType.GIF {
                self.gifsTypeSelect(animation: true)
            } else {
                self.stickerTypeSelect(animation: true)
            }
            
            self.gifCollectionView.contentOffset = CGPoint(x: 0, y: 0)
        }.disposed(by: disposeBag)
        
        gifTypeView.rx.tapGesture().when(.recognized)
            .map { _ in Reactor.Action.searchItemTypeChange(ItemType.GIF) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        stickerTypeView.rx.tapGesture().when(.recognized)
            .map { _ in Reactor.Action.searchItemTypeChange(ItemType.STICKER) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}
 
extension SearchViewController: UICollectionViewDelegateFlowLayout, DynamicLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath, width: CGFloat) -> CGFloat {
        
        if let obj = reactor?.currentState.gifObjs {
            guard obj.count > indexPath.row else {
                print("obj.count < indexPath.row")
                return 0
            }
            
            if let strHeight = obj[indexPath.row].images?.thumbnail?.height, let _height = Float(strHeight),
               let strWidth = obj[indexPath.row].images?.thumbnail?.width, let _width = Float(strWidth){
                return CGFloat(_height) * CGFloat(width) / CGFloat(_width)
            }
        }

        return 0
    } 
}
  
