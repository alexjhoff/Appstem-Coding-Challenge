//
//  ImageSearchViewModel.swift
//  AppstemProject
//
//  Created by Alex Hoff on 5/30/18.
//

import Foundation
import UIKit

enum ImageSearchViewModelItemType {
    case search
    case result
    case images
}

protocol ImageViewProtocol {
    func reloadView()
    func pushModalViewWithImage(_ image: UIImage)
}

protocol ImageSearchViewModelItem {
    var type: ImageSearchViewModelItemType { get }
    var dimensions: (CGFloat,CGFloat) { get }
    var rowCount: Int { get }
}

extension ImageSearchViewModelItem {
    var rowCount: Int {
        return 1
    }
}

class ImageSearchViewModel: NSObject {
    
    //Collection view items
    fileprivate var items = [ImageSearchViewModelItem]()
    
    //Image request so that the request is not deallocated when the function goes out of scope
    fileprivate var apiRequest: ApiRequest?
    
    //Array of image models
    fileprivate var images: [Image]?
    
    //Image cache
    fileprivate let imageCache = NSCache<NSString, UIImage>()
    
    //Pre-fetching queue and and operations array
    fileprivate let imageLoadQueue = OperationQueue()
    fileprivate var imageLoadOperations = [IndexPath: ImageLoadOperation]()
    
    //Spell checker
    fileprivate var checker: SpellCheck?
    
    //Delegate to communicate with the view
    var delegate: ImageViewProtocol?
    
    override init() {
        super.init()
        
        // Add search bar cell to collection view data source
        let searchItem = ImageSearchItem()
        items.append(searchItem)
        
        // Create SpellCheck with resource
        if let fileUrl = Bundle.main.path(forResource: "google-10000-english-no-swears", ofType: "txt") {
            do {
                let data = try String(contentsOf: URL(fileURLWithPath: fileUrl))
                checker = SpellCheck(contentsOfFile: data)
            } catch {
                print("Error fetching word dictionary")
            }
        }
    }
    
    func getImagesWithQuery(_ query: String, completion: @escaping () -> Void) {
        var targetWord: String
        var wasCorrected = false
        
        // Makes sure to remove old image values
        if items.count > 1 {
            items.removeLast(2)
            delegate?.reloadView()
        }

        // Checks the word for correctness
        if let checked = checker?.correct(word: query) {
            wasCorrected = query == checked ? false : true
            targetWord = checked
        } else {
            targetWord = query
            print("Checker is broken")
        }
        
        // URL request to find the image urls from the query word
        let urlRequest = URLRequest.buildUrlWithPhrase(targetWord)
        let urlSession = URLSession.shared
        apiRequest = ApiRequest(url: urlRequest, session: urlSession)
        apiRequest?.load { [weak self] (session: Session?) in
            guard let strongSelf = self else { fatalError("Weak self deallocated") }
            guard let images = session?.images else { return }
            strongSelf.images = images
            
            // Add results to collection view data source
            let result = SearchResultItem(term: targetWord, wasCorrected: wasCorrected)
            strongSelf.items.append(result)
            let resultImages = ImagesItem(images: images)
            strongSelf.items.append(resultImages)
            
            strongSelf.delegate?.reloadView()
            completion()
        }
    }
    
    // Function to set the image once found on the main thread
    func setImage(_ image: UIImage, forCell cell: ImageCollectionViewCell, withIndex index: Int) {
        DispatchQueue.main.async {
            if cell.tag == index {
                cell.imageView.image = image
                cell.imageView.contentMode = UIViewContentMode.scaleAspectFit
            }
        }
    }
}

extension ImageSearchViewModel: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let item = items[section]
        return item.rowCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = items[indexPath.section]
        switch item.type {
        case .search:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchCollectionViewCell.identifier, for: indexPath) as? SearchCollectionViewCell {
                cell.viewModel = self
                return cell
            }
        case .result:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchResultCollectionViewCell.identifier, for: indexPath) as? SearchResultCollectionViewCell {
                cell.item = item
                return cell
            }
        case .images:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier, for: indexPath) as? ImageCollectionViewCell,
                let images = images {
                cell.imageView.image = nil
                cell.tag = indexPath.row
                
                // Check if the image is already in the imageCache
                let imageUrl = images[indexPath.row].displaySizes[0].uri
                if let cachedImage = imageCache.object(forKey: imageUrl as NSString) {
                    setImage(cachedImage, forCell: cell, withIndex: indexPath.row)
                    return cell
                }
                
                /*
                 If not, check if the image load operation is already been completed
                 and is sitting with the image in the operations array.
                 If so the image will be cached and the cells image is set.
                 */
                if let imageLoadOperation = imageLoadOperations[indexPath],
                    let image = imageLoadOperation.image {
                    imageCache.setObject(image, forKey: imageUrl as NSString)
                    setImage(image, forCell: cell, withIndex: indexPath.row)
                }
                else {
                    /*
                     If the load operation has not been made it is added to the operation queue
                     and the image cache and cell image are set once the operation is complete
                     */
                    let imageLoadOperation = ImageLoadOperation(url: imageUrl)
                    imageLoadOperation.completionHandler = { [weak self] (image) in
                        guard let strongSelf = self else { return }
                        strongSelf.imageCache.setObject(image, forKey: imageUrl as NSString)
                        strongSelf.setImage(image, forCell: cell, withIndex: indexPath.row)
                        strongSelf.imageLoadOperations.removeValue(forKey: indexPath)
                    }
                    imageLoadQueue.addOperation(imageLoadOperation)
                    imageLoadOperations[indexPath] = imageLoadOperation
                }
                return cell
            }
        }
        return UICollectionViewCell()
    }
    
    // Set the dimensions of the cells
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = items[indexPath.section]
        return CGSize(width: item.dimensions.0, height: item.dimensions.1)
    }
}

extension ImageSearchViewModel: UICollectionViewDelegate {
    // If the cell goes out of view and the operation for that cell is not complete the opeartion is canceled
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let imageLoadOperation = imageLoadOperations[indexPath] else { return }
        imageLoadOperation.cancel()
        imageLoadOperations.removeValue(forKey: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell,
            let image = cell.imageView.image {
            self.delegate?.pushModalViewWithImage(image)
        }
    }
}

class ImageSearchItem: ImageSearchViewModelItem {
    
    var type: ImageSearchViewModelItemType {
        return .search
    }
    
    var dimensions: (CGFloat, CGFloat) {
        let screenWidth = UIScreen.main.bounds.width
        let cellWidth = screenWidth - 20
        return (cellWidth, 62)
    }
}

class SearchResultItem: ImageSearchViewModelItem {
    
    var type: ImageSearchViewModelItemType {
        return .result
    }
    
    var dimensions: (CGFloat, CGFloat) {
        let screenWidth = UIScreen.main.bounds.width
        let cellWidth = screenWidth - 20
        return (cellWidth, 45)
    }
    
    var term: String
    var wasCorrected: Bool
    
    init(term: String, wasCorrected: Bool) {
        self.term = term
        self.wasCorrected = wasCorrected
    }
}

class ImagesItem: ImageSearchViewModelItem {
    
    var type: ImageSearchViewModelItemType {
        return .images
    }
    
    var dimensions: (CGFloat, CGFloat) {
        let screenWidth = UIScreen.main.bounds.width
        let cellWidth = (screenWidth - 60.0)/2
        return (cellWidth,180)
    }
    
    var rowCount: Int {
        return images.count
    }
    
    var images: [Image]
    
    init(images: [Image]) {
        self.images = images
    }
}




