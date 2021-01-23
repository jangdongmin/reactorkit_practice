//
//  GiphySearchReactor.swift
//  GIPHY_SAMPLE
//
//  Created by Paul Jang on 2021/01/12.
//

import UIKit

protocol DynamicLayoutDelegate: class {
    func collectionView(_ collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath, width: CGFloat) -> CGFloat
}

class DynamicLayout: UICollectionViewLayout {
    weak var delegate: DynamicLayoutDelegate?
    
    fileprivate var numberOfColumns = 2
    fileprivate var cellPadding: CGFloat = 2
    fileprivate var cache = [UICollectionViewLayoutAttributes]()
    fileprivate var contentHeight: CGFloat = 0
    
    fileprivate var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        guard let collectionView = collectionView else {
            return
        }
        
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset = [CGFloat]()
        for column in 0 ..< numberOfColumns {
            if column == 0 {
                xOffset.append(CGFloat(column) * columnWidth)
            } else {
                xOffset.append(CGFloat(column) * columnWidth + cellPadding)
            }
        }
        var column = 0
        var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
        
        guard collectionView.numberOfSections > 0 else {
            return
        }
        
        cache.removeAll()
        contentHeight = 0
        
        for i in 0 ..< collectionView.numberOfItems(inSection: 0) {
            
            let indexPath = IndexPath(item: i, section: 0)
            
            if let photoHeight = delegate?.collectionView(collectionView, heightForPhotoAtIndexPath: indexPath, width: columnWidth) {
                let  height: CGFloat = cellPadding + photoHeight
                
                let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
                
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = frame
                cache.append(attributes)
                
                contentHeight = max(contentHeight, frame.maxY)
                yOffset[column] = yOffset[column] + height
                
                column = column < (numberOfColumns - 1) ? (column + 1) : 0
            }
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }    
}
