//
//  UpdatesVC.swift
//  WhatsAppStoryView
//
//  Created by Raju Kumar on 01/10/23.
//

import UIKit

final class UpdatesVC: UIViewController {
    
    //MARK: -IBoutlets
    @IBOutlet weak var statusCollectionVw: UICollectionView!
    
    
    var arrPeople: [StatusModel]?
    
    //MARK: -Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerNib()
        self.configureCompositionalLayout()
        self.loadJSONDataFromFile()
    }
    
    //MARK: -Functions
    private func registerNib() {
        self.statusCollectionVw.translatesAutoresizingMaskIntoConstraints = false
        self.statusCollectionVw.delegate = self
        self.statusCollectionVw.dataSource = self
        self.statusCollectionVw.register(UINib(nibName: "StatusCVCell", bundle: nil), forCellWithReuseIdentifier: "StatusCVCell")
        self.statusCollectionVw.register(UINib(nibName: "HeaderCVCell", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderCVCell")
    }
    
    private func configureCompositionalLayout() {
        let collection_layout = UICollectionViewCompositionalLayout {sectionIndex, environment in
                return Layouts.shared.statusListLayout()
        }
        self.statusCollectionVw.setCollectionViewLayout(collection_layout, animated: true)
    }

    // Define a function to read JSON data from a file and decode it
    func loadJSONDataFromFile() {
        if let fileURL = Bundle.main.url(forResource: "Status", withExtension: "json") {
            do {
                let jsonData = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                let data = try decoder.decode(Status.self, from: jsonData)
                if let arrPeople = data.status {
                    self.arrPeople = arrPeople
                    self.statusCollectionVw.reloadData()
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
    }
}

//MARK: -Extensions
extension UpdatesVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrPeople?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderCVCell", for: indexPath) as? HeaderCVCell else {return UICollectionReusableView()}
            return header
            
        default:
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatusCVCell", for: indexPath) as? StatusCVCell else { return UICollectionViewCell()}
        cell.initCircularProgressBar()
        cell.nameLbl.text = self.arrPeople?[indexPath.row].name
        cell.imgVw.downloadImage(url: self.arrPeople?[indexPath.row].profile_image)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Story", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "StoryVC") as! StoryVC
        vc.modalPresentationStyle = .overFullScreen
        if let data = self.arrPeople {
            vc.arrayStories = data
        }
        vc.selectedStoryIndex = indexPath.row
        self.present(vc, animated: true, completion: nil)
    }
}
