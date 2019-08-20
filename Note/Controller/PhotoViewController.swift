//
//  PhotoViewController.swift
//  Note
//
//  Created by Максим Бачурин on 20/07/2019.
//  Copyright © 2019 Максим Бачурин. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {
    var imageViews = [UIImageView]()
    var currentPhoto = 0
    var taped = false

    @IBOutlet weak var scrollView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        navigationController?.hidesBarsOnTap = true
        addGesture()
    }
    
    override func viewDidLayoutSubviews() {
        addImageViewsOnScrollView()
    }
    
    func addGesture() {
        if let tapGesture = navigationController?.barHideOnTapGestureRecognizer {
            tapGesture.addTarget(self, action: #selector(tapGesture(_:)))
            scrollView.addGestureRecognizer(navigationController!.barHideOnTapGestureRecognizer)
        }
    }
    
    func addImageViewsOnScrollView() {
        scrollView.contentSize = CGSize(width: scrollView.bounds.width * CGFloat(imageViews.count),
                                        height: scrollView.bounds.height)
        for (index, imageView) in imageViews.enumerated() {
            scrollView.addSubview(imageView)
            imageView.frame.origin.x = scrollView.bounds.width * CGFloat(index)
            imageView.frame.origin.y = 0
            imageView.frame.size = scrollView.bounds.size
            imageView.contentMode = .scaleAspectFit
        }
        scrollView.isPagingEnabled = true
        scrollView.contentOffset.x = CGFloat(currentPhoto) * scrollView.bounds.width
    }
    
    func addImages(images: [UIImage]) {
        for image in images {
            let imageView = UIImageView(image: image)
            imageViews.append(imageView)
        }
    }
    
    @objc func tapGesture(_ sender: UITapGestureRecognizer) {
        if taped {
            scrollView.backgroundColor = nil
        } else {
            scrollView.backgroundColor = .black
        }
        taped = !taped
    }
}

extension PhotoViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentPhoto = Int(CGFloat(scrollView.contentOffset.x)/CGFloat(scrollView.bounds.width))
    }
}
