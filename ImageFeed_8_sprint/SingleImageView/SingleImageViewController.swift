//
//  SingleImageViewController.swift
//  ImageFeed_8_sprint
//
//  Created by Марат Хасанов on 19.09.2023.
//

import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    var imageURL: URL! {
        didSet {
            guard isViewLoaded else {return}
            setImage()
        }
    }
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        setImage()
    }
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let image = imageURL else { return }
        let share = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(share, animated: true)
    }
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    private func setImage() {
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: imageURL) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let imageResult):
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
            case .failure:
                print("error")
            }
            UIBlockingProgressHUD.dismiss()
        }
    }
    
    //Чтобы центр изображения совпадал с центром скролла
     private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}
//Метод делегата, вернем View, которую хотим зумить
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
