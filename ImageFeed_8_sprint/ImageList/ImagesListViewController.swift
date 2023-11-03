//
//  ViewController.swift
//  ImageFeed_8_sprint
//
//  Created by Марат Хасанов on 30.08.2023.
//

import UIKit
import SwiftKeychainWrapper
import Kingfisher

//Основной экран показа картинок
class ImagesListViewController: UIViewController {
    
    private var imageListServiceObserber: NSObjectProtocol?
    
    private let imageListService = ImageListService.shared
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    var photos: [Photo] = []
    
    @IBOutlet private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
//        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
//        tableView.dataSource = self
        navigationController?.setNavigationBarHidden(true, animated: false)
        imageListServiceObserber = NotificationCenter.default
            .addObserver(
                forName: ImageListService.didChangeNotification,
                object: nil,
                queue: .main) { [weak self] _ in
                    guard let self = self else { return }
                    self.updateTableView()
                }
        imageListService.fetchPhotosNextPage()
    }
    
    func updateTableView() {
        let oldCount = photos.count
        let newCount = imageListService.photos.count
        photos = imageListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPath = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPath, with: .automatic)
            } completion: { _ in }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: ImageListService.didChangeNotification, object: nil)
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            let viewController = segue.destination as! SingleImageViewController
            let indexPath = sender as! IndexPath
            let photo = photos[indexPath.row]
            guard let imageURL = URL(string: photo.largeImageURL) else { return }
            viewController.imageURL = imageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController {
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let imageUrl = photos[indexPath.row].thumbImageURL
        let url = URL(string: imageUrl)
        let placeholder = UIImage(named: "Stubs")
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(with: url, placeholder: placeholder){[weak self] _ in
            guard let self = self else { return }
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
            cell.cellImage.kf.indicatorType = .none
        }
        if let date = imageListService.photos[indexPath.row].createdAt {
            cell.dateLabel.text = dateFormatter.string(from: date)
        } else {
            cell.dateLabel.text = "Пусто"
        }
        let isLiked = imageListService.photos[indexPath.row].isLiked == false
        let like = isLiked ? UIImage(named: "dislike") : UIImage(named: "like")
        cell.likeButton.setImage(like, for: .normal)
        cell.selectionStyle = .none
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == imageListService.photos.count {
            imageListService.fetchPhotosNextPage()
        }
    }
}

extension ImagesListViewController: UITableViewDelegate {
    //Отвечает за действия, которые будут выполнены при тапе по ячейке
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    //Вычисление высоты ячеек
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = photos[indexPath.row]
        let imageSize = CGSize(width: cell.size.width, height: cell.size.height)
        let aspectRatio = imageSize.width / imageSize.height
        return tableView.frame.width / aspectRatio
    }
}

extension ImagesListViewController: UITableViewDataSource {
    //сколько ячеек будет в конкретной секции
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    //созд. ячейку и наполняем ее данными - передаем таблице
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        imageListCell.delegate = self
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imageListService.like(id: photo.id, isLike: photo.isLiked) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.photos = self.imageListService.photos
                    cell.establishLike(isLiked: self.photos[indexPath.row].isLiked)
                    UIBlockingProgressHUD.dismiss()
                case .failure(let error):
                    UIBlockingProgressHUD.dismiss()
                    self.errorLikeAlert(with: error)
                }
            }
        }
    }

    
    private func errorLikeAlert(with error: Error) {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось поставить лайк",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }
}
    

/* Механизм переиспользования
 
 Таблица запрашивает общее кол-во элементов
 Таблица запрашивает примерную высоут всех ячеек и определяет примерный contentSize
 Исходя из contentSize и Bounds определяются индексы которые должны быть отрисованы
 Ячейки получаются методом dequeueResusableCell
 Перед отображением ячеек выставляется их финальная высота tableView(..heightForRowAt)
 */
