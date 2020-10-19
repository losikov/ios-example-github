//
//  UsersCollectionViewLayout.swift
//  GitHub
//
//  Created by Alexander Losikov on 10/18/20.
//  Copyright © 2020 Alexander Losikov. All rights reserved.
//

import UIKit

extension CGRect {
    func dividedIntegral(fraction: CGFloat, from fromEdge: CGRectEdge) -> (first: CGRect, second: CGRect) {
        let dimension: CGFloat
        
        switch fromEdge {
        case .minXEdge, .maxXEdge:
            dimension = self.size.width
        case .minYEdge, .maxYEdge:
            dimension = self.size.height
        }
        
        let distance = (dimension * fraction).rounded(.up)
        var slices = self.divided(atDistance: distance, from: fromEdge)
        
        switch fromEdge {
        case .minXEdge, .maxXEdge:
            slices.slice.size.width -= CGFloat.cellSpacing/2
            slices.remainder.origin.x += CGFloat.cellSpacing/2
            slices.remainder.size.width -= CGFloat.cellSpacing/2
        case .minYEdge, .maxYEdge:
            slices.remainder.origin.y += 1
            slices.remainder.size.height -= 1
        }
        
        return (first: slices.slice, second: slices.remainder)
    }
}

enum UserViewStyle {
    case fiftyFifty
    case fullWidth
    case doubleHeight
}

class UsersCollectionViewLayout: UICollectionViewLayout {
    
    var contentBounds = CGRect.zero
    var cachedAttributes = [UICollectionViewLayoutAttributes]()
    
    /// - Tag: PrepareUsersCollectionViewLayout
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }

        // Reset cached information.
        cachedAttributes.removeAll()
        contentBounds = CGRect(origin: .zero, size: collectionView.bounds.size)
        
        // For every item in the collection view:
        //  - Prepare the attributes.
        //  - Store attributes in the cachedAttributes array.
        //  - Combine contentBounds with attributes.frame.
        let count = collectionView.numberOfItems(inSection: 0)
        
        var currentIndex = 0
        var segment: UserViewStyle = .fiftyFifty
        var lastFrame: CGRect = .zero
        
        let spacing = CGFloat.cellSpacing
        let cellWidth = collectionView.bounds.size.width - spacing*2
        let cellHeight = cellWidth/2
        
        while currentIndex < count {
            var segmentRects = [CGRect]()
            switch segment {
            case .fiftyFifty:
                let segmentFrame = CGRect(x: spacing, y: lastFrame.maxY + 1.0 + spacing, width: cellWidth, height: cellHeight)
                let horizontalSlices = segmentFrame.dividedIntegral(fraction: 0.5, from: .minXEdge)
                segmentRects = [horizontalSlices.first, horizontalSlices.second]
                
            case .fullWidth:
                segmentRects = [CGRect(x: spacing, y: lastFrame.maxY + 1.0 + spacing, width: cellWidth, height: cellHeight)]
                
            case .doubleHeight:
                segmentRects = [CGRect(x: spacing, y: lastFrame.maxY + 1.0 + spacing, width: cellWidth, height: 2*cellHeight)]
            }
            
            // Create and cache layout attributes for calculated frames.
            for rect in segmentRects {
                if currentIndex < count {
                    let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: currentIndex, section: 0))
                    cachedAttributes.append(attributes)
                    
                    attributes.frame = rect
                    lastFrame = rect
                    currentIndex += 1
                    
                    contentBounds = contentBounds.union(lastFrame)
                }
            }

            // Determine the next segment style.
            switch currentIndex {
            case 2:
                segment = .fullWidth
            case 3:
                segment = .doubleHeight
            default:
                switch segment {
                case .fiftyFifty:
                    segment = .fullWidth
                case .fullWidth:
                    segment = .doubleHeight
                case .doubleHeight:
                    segment = .fiftyFifty
                }
            }
        }
    }

    /// - Tag: CollectionViewContentSize
    override var collectionViewContentSize: CGSize {
        return contentBounds.size
    }
    
    /// - Tag: ShouldInvalidateLayout
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return false }
        return !newBounds.size.equalTo(collectionView.bounds.size)
    }
    
    /// - Tag: LayoutAttributesForItem
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedAttributes[indexPath.item]
    }
    
    /// - Tag: LayoutAttributesForElements
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributesArray = [UICollectionViewLayoutAttributes]()
        
        // Find any cell that sits within the query rect.
        guard let lastIndex = cachedAttributes.indices.last,
              let firstMatchIndex = binSearch(rect, start: 0, end: lastIndex) else { return attributesArray }
        
        // Starting from the match, loop up and down through the array until all the attributes
        // have been added within the query rect.
        for attributes in cachedAttributes[..<firstMatchIndex].reversed() {
            guard attributes.frame.maxY >= rect.minY else { break }
            attributesArray.append(attributes)
        }
        
        for attributes in cachedAttributes[firstMatchIndex...] {
            guard attributes.frame.minY <= rect.maxY else { break }
            attributesArray.append(attributes)
        }
        
        return attributesArray
    }
    
    // Perform a binary search on the cached attributes array.
    func binSearch(_ rect: CGRect, start: Int, end: Int) -> Int? {
        if end < start { return nil }
        
        let mid = (start + end) / 2
        let attr = cachedAttributes[mid]
        
        if attr.frame.intersects(rect) {
            return mid
        } else {
            if attr.frame.maxY < rect.minY {
                return binSearch(rect, start: (mid + 1), end: end)
            } else {
                return binSearch(rect, start: start, end: (mid - 1))
            }
        }
    }

}
