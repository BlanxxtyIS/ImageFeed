//
//  ViewController.swift
//  ImageFeed_8_sprint
//
//  Created by Марат Хасанов on 30.08.2023.
//

import UIKit
import Kingfisher

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListViewPresenterProtocol { get set }
    var tableView: UITableView! { get set }
    func setupTableView()
    func errorLikeAlert(error: Error)
}


//Основной экран показа картинок
final class ImagesListViewController: UIViewController {
    var photosCount: Int {
        photos.count
    }
    private var imageListServiceObserber: NSObjectProtocol?
    
    private let imageListService = ImageListService.shared
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    var photos: [Photo] = []
    
    @IBOutlet public var tableView: UITableView!
    
    var presenter = ImagesListViewPresenter() as ImagesListViewPresenterProtocol
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        startObserveImagesListChanges()
    }

    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopObserveImagesListChanges()
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
}

extension ImagesListViewController: UITableViewDelegate {
    //Отвечает за действия, которые будут выполнены при тапе по ячейке
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    //Вычисление высоты ячеек
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        presenter.calculateHeightForRow(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter.chekIfNextPageNeeded(indexPath: indexPath)
    }
}

extension ImagesListViewController: UITableViewDataSource {
    //сколько ячеек будет в конкретной секции
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(presenter.photosCount)
        return presenter.photosCount
    }
    
    //созд. ячейку и наполняем ее данными - передаем таблице
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        print(cell)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return print("не удалось получить индекс ячейки") }
        presenter.imagesListCellDidTapLike(cell, indexPath: indexPath)
    }
    
    internal func errorLikeAlert(error: Error) {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось поставить лайк",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }
}

extension ImagesListViewController {
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        cell.delegate = self
        cell.likeButton.accessibilityIdentifier = "LikeButton"
        let imageUrl = presenter.returnPhoto(indexPath: indexPath).thumbImageURL
        let url = URL(string: imageUrl)
        let placeholder = UIImage(named: "Stubs")
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(with: url, placeholder: placeholder){[weak self] _ in
            guard let self = self else { return }
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
            cell.cellImage.kf.indicatorType = .none
        }
        if let date = presenter.returnPhoto(indexPath: indexPath).createdAt {
            cell.dateLabel.text = dateFormatter.string(from: date)
        } else {
            cell.dateLabel.text = "Пусто"
        }
        let isLiked = presenter.returnPhoto(indexPath: indexPath).isLiked
        let likeImage = isLiked ? UIImage(named: "dislike") : UIImage(named: "like")
        cell.likeButton.setImage(likeImage, for: .normal)
        cell.selectionStyle = .none
    }
    
    private func startObserveImagesListChanges() {
        imageListServiceObserber = NotificationCenter.default.addObserver(forName: ImageListService.didChangeNotification, object: nil, queue: .main) { [weak self] _ in
            self?.presenter.updateTableViewAnimated()
        }
    }
    
    private func stopObserveImagesListChanges() {
        NotificationCenter.default.removeObserver(self, name: ImageListService.didChangeNotification, object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            let viewController = segue.destination as! SingleImageViewController
            let indexPath = sender as! IndexPath
            let imageUrl = presenter.returnPhoto(indexPath: indexPath).largeImageURL
            viewController.image = URL(string: imageUrl)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func updateTableViewAnimated() {
        presenter.updateTableViewAnimated()
    }
}

extension ImagesListViewController: ImagesListViewControllerProtocol {
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
}
