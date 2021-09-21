//
//  ImplementacionVC.swift
//  Initiative
//
//  Created by Andres Liu on 11/10/20.
//

import UIKit
import Alamofire
import SwiftyJSON

class ImplementacionFilterCellClass: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.accessoryType = selected ? .checkmark : .none
    }
}

class ImplementacionVC: UIViewController {

    @IBOutlet weak var buttonCampaign: UIButton!
    
    @IBOutlet weak var buttonMedia: UIButton!
    
    @IBOutlet weak var campaignTableView: UITableView!
    
    var arrayCampaigns = [Campaign]()
    
    
    let transparentView = UIView()
    let borderView = UIView()
    let inBetweenView = UIView()
    let searchBar = UISearchBar()
    let tableView = UITableView()
    var selectedButton = UIButton()
    var imageView = ImageViewWithUrl()
    
    var dataSource = [FilterBody]()
    var dataSearch = [FilterBody]()
    var searching = false
    var didSelect = false
    
    var arrayCampaign = [Int]()
    var arrayMedia = [Int]()
    var arrayBeforeFilter = [Int]()
    
    var mediaList = [FilterBody]()
    var campaignList = [FilterBody]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchBar.delegate = self
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(ImplementacionFilterCellClass.self, forCellReuseIdentifier: "ImplementacionCell")
//        self.tableView.allowsMultipleSelection = true
//        self.tableView.allowsMultipleSelectionDuringEditing = true
        
        campaignTableView.dataSource = self
        campaignTableView.delegate = self
        campaignTableView.backgroundColor = UIColor(rgb: 0xF2EFE9)
        
        buttonCampaign.addBorders(width: 1)
        buttonMedia.addBorders(width: 1)
        buttonCampaign.titleEdgeInsets.left = 10
        buttonMedia.titleEdgeInsets.left = 10
        buttonCampaign.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        buttonMedia.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        
        getMedia()
        //getCampaign()
        //getCampaigns()
    }
    
    func getMedia(){
        let serverManager = ServerManager()
        let parameters : Parameters  = ["idBrand": UserDefaults.standard.string(forKey: "idBrand")!]
        serverManager.serverCallWithHeaders(url: serverManager.mediaURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                guard !jsonData.isEmpty else {
                    self.validateEntryData(title: "Error", message: "No hay datos de medios")
                    return
                }
                var count = 1
                for media in jsonData["mediaInversionList"].arrayValue {
                    let newMedia: FilterBody = FilterBody(id: media["id"].int!, name: media["name"].string!)
                    self.mediaList.append(newMedia)
                    if count == 1 {
                        self.buttonMedia.setTitle(newMedia.name, for: .normal)
                        self.arrayMedia.append(newMedia.id)
                    }
                    count += 1
                }
                self.getCampaign()
            } else {
                print("Failure")
            }
        })
    }
    
    public func getCampaign(){
        let serverManager = ServerManager()
        let parameters : Parameters  = ["idBrand": UserDefaults.standard.string(forKey: "idBrand")!]
        serverManager.serverCallWithHeaders(url: serverManager.implementacionCampaignsURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                guard !jsonData.isEmpty else {
                    self.validateEntryData(title: "Error", message: "No hay datos de campañas")
                    return
                }
                var count = 1
                for campaign in jsonData["campaignList"].arrayValue {
                    let isContained = self.campaignList.contains { $0.id == campaign["idCampaign"].int! }
                    
                    if !isContained {
                        let newCampaign: FilterBody = FilterBody(id: campaign["idCampaign"].int!, name: campaign["name"].string!)
                        self.campaignList.append(newCampaign)
                        if count == 1 {
                            self.buttonCampaign.setTitle(newCampaign.name, for: .normal)
                            self.arrayCampaign.append(newCampaign.id)
                        }
                        count += 1
                    }
                }
                self.getCampaigns()
            } else {
                print("Failure")
            }
        })
    }
    
    func getCampaigns() {
        let serverManager = ServerManager()
        let parameters : Parameters  = ["idBrand": UserDefaults.standard.string(forKey: "idBrand")!, "idCampaign": arrayCampaign[0], "idMedium": arrayMedia[0]]
        
        serverManager.serverCallWithHeaders(url: serverManager.campaignURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                guard !jsonData.isEmpty else {
                    self.showAlert(title: "Error", message: "No hay datos con determinado filtro")
                    return
                }
                self.arrayCampaigns.removeAll()
                print(jsonData)
                for campaign in jsonData["categories"].arrayValue {
                    let campaignElement = Campaign(name: jsonData["title"].string!, categoryTitle: campaign["categoryTitle"].string!, imageUrl: campaign["imageUrl"].string!, date: campaign["date"].string ?? "", media: campaign["medium"].string!)
                    self.arrayCampaigns.append(campaignElement)
                }
                print(self.arrayCampaigns)
                print(self.arrayCampaigns.count)
                self.campaignTableView.reloadData()
            } else {
                self.showAlert(title: "Error", message: "Datos no fueron cargados correctamente")
            }
        })
    }
    
    func addTransparentView(searchPlaceholder: String) {
        //let window = UIApplication.shared.keyWindow
        let frames = self.view.frame
        transparentView.frame = self.view.frame
        self.view.addSubview(transparentView)
        
        self.view.addSubview(borderView)
        self.view.addSubview(searchBar)
        self.view.addSubview(inBetweenView)
        self.view.addSubview(tableView)
        
        self.borderView.frame = CGRect(x: frames.minX, y: frames.maxY, width: frames.width, height: 0)
        self.searchBar.frame = CGRect(x: frames.minX + 30, y: frames.maxY, width: frames.width - 60, height: 0)
        self.inBetweenView.frame = CGRect(x: frames.minX, y: frames.maxY, width: frames.width - 60, height: 0)
        self.tableView.frame = CGRect(x: frames.minX + 30, y: frames.maxY, width: frames.width - 60, height: 0)
        
        
        let searchTextField: UITextField? = searchBar.value(forKey: "searchField") as? UITextField
            if searchTextField!.responds(to: #selector(getter: UITextField.attributedPlaceholder)) {
                let attributeDict = [NSAttributedString.Key.foregroundColor: UIColor.black]
                searchTextField!.attributedPlaceholder = NSAttributedString(string: "Buscar \(searchPlaceholder)", attributes: attributeDict)
            }
        
        borderView.layer.cornerRadius = 20
        borderView.layer.backgroundColor = #colorLiteral(red: 0.1048603281, green: 0.137150079, blue: 0.1497618556, alpha: 1)
        searchBar.layer.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        inBetweenView.layer.backgroundColor = #colorLiteral(red: 0.1048603281, green: 0.137150079, blue: 0.1497618556, alpha: 1)
        
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        tableView.reloadData()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeTransparentView))
        
        transparentView.addGestureRecognizer(tapGesture)
        transparentView.alpha = 0
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .transitionCurlDown, animations: {
            self.transparentView.alpha = 0.5
            self.borderView.frame = CGRect(x: frames.minX, y: frames.maxY - 400, width: frames.width, height: 420)
            self.searchBar.frame = CGRect(x: frames.minX + 30, y: frames.maxY - 370, width: frames.width - 60, height: 50)
            self.inBetweenView.frame = CGRect(x: frames.minX + 30, y: frames.maxY - 320, width: frames.width - 60, height: 20)
            self.tableView.frame = CGRect(x: frames.minX + 30, y: frames.maxY - 300, width: frames.width - 60, height: 300)
        }, completion: nil)
    }
    
    @objc func removeTransparentView() {
        let frames = self.view.frame
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .transitionCurlDown, animations: {
            self.transparentView.alpha = 0
            self.borderView.frame = CGRect(x: frames.minX, y: frames.maxY, width: frames.width, height: 0)
            self.searchBar.frame = CGRect(x: frames.minX + 30, y: frames.maxY, width: frames.width - 60, height: 0)
            self.inBetweenView.frame = CGRect(x: frames.minX, y: frames.maxY, width: frames.width - 60, height: 0)
            self.tableView.frame = CGRect(x: frames.minX + 30, y: frames.maxY, width: frames.width - 60, height: 0)
            self.imageView.frame = CGRect(x: frames.minX + 30, y: frames.maxY, width: frames.width - 60, height: 0)
            self.searchBar.text = ""
            self.searching = false
            self.tableView.reloadData()
            self.searchBar.resignFirstResponder()
        }, completion: nil)
        
        if didSelect {
            getCampaigns()
            didSelect = false
        } else {
            if arrayMedia.isEmpty {
                arrayMedia = arrayBeforeFilter
            }
            if arrayCampaign.isEmpty {
                arrayCampaign = arrayBeforeFilter
            }
            print("No hubo cambio en filtro")
        }
    }
    
    @objc func showImageView() {
        transparentView.frame = self.view.frame
        self.view.addSubview(transparentView)
        self.view.addSubview(imageView)
        
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeTransparentView))
        
        transparentView.addGestureRecognizer(tapGesture)
        transparentView.alpha = 0
        
        let imageUrl = imageView.url!
        if let url = NSURL(string: imageUrl) {
            if let data = NSData(contentsOf: url as URL) {
                imageView.image = UIImage(data: data as Data)
            }
        }
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .transitionCurlDown, animations: {
            self.transparentView.alpha = 0.5
            self.imageView.frame = CGRect(x: (self.view.frame.maxX - self.imageView.image!.size.width)/2, y: (self.view.frame.maxY - self.imageView.image!.size.height)/2, width: self.imageView.image!.size.width, height: self.imageView.image!.size.height)
        }, completion: nil)
    }
    
    @IBAction func returnToReportList(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickBtnCampaign(_ sender: UIButton) {
        dataSource = campaignList
        selectedButton = buttonCampaign
        arrayBeforeFilter = arrayCampaign
        arrayCampaign.removeAll()
        didSelect = false
        tableView.reloadData()
        addTransparentView(searchPlaceholder: "campaña...")
    }
    

    @IBAction func onClickBtnMedia(_ sender: UIButton) {
        dataSource = mediaList
        selectedButton = buttonMedia
        arrayBeforeFilter = arrayMedia
        arrayMedia.removeAll()
        didSelect = false
        tableView.reloadData()
        addTransparentView(searchPlaceholder: "media...")
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
       let size = image.size

       let widthRatio  = targetSize.width  / size.width
       let heightRatio = targetSize.height / size.height

       // Figure out what our orientation is, and use that to form the rectangle
       var newSize: CGSize
       if(widthRatio > heightRatio) {
           newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
       } else {
           newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
       }

       // This is the rect that we've calculated out and this is what is actually used below
       let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

       // Actually do the resizing to the rect using the ImageContext stuff
       UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
       image.draw(in: rect)
       let newImage = UIGraphicsGetImageFromCurrentImageContext()
       UIGraphicsEndImageContext()

       return newImage!
   }
}

extension ImplementacionVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == campaignTableView {
            return arrayCampaigns.count
        } else {
            if searching {
                return dataSearch.count
            } else {
                return dataSource.count
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == campaignTableView {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "CampaignCell")
            
            let eyeImg = UIImage(systemName: "eye")!.withTintColor(.black, renderingMode: .alwaysOriginal)
            cell.imageView!.image = eyeImg
            self.imageView.url = arrayCampaigns[indexPath.row].imageUrl
            cell.imageView!.isUserInteractionEnabled = true
            let onTap = UITapGestureRecognizer(target: self, action: #selector(showImageView))
            onTap.numberOfTouchesRequired = 1
            onTap.numberOfTapsRequired = 1
            cell.imageView!.addGestureRecognizer(onTap)
            
            cell.backgroundColor = UIColor(rgb: 0xF2EFE9)
            cell.textLabel?.font = UIFont(name: "Aldine721BT-Roman",
                                          size: 15.0)
            cell.detailTextLabel?.font = UIFont(name: "Aldine721BT-Roman",
                                               size: 12.0)
            
            cell.textLabel?.text = "\(arrayCampaigns[indexPath.row].categoryTitle) \(arrayCampaigns[indexPath.row].name)"
            
            cell.detailTextLabel?.text = arrayCampaigns[indexPath.row].date
            
            var rightImg = UIImage(named: "enProceso_icono")!
            if arrayCampaigns[indexPath.row].date == "" {
                rightImg = UIImage(named: "enProceso_icono")!
            } else {
                rightImg = UIImage(named: "alAire_icono")!
            }
            let dateImg = resizeImage(image: rightImg, targetSize: CGSize(width: 80.0, height: 40.0))
            cell.accessoryView = UIImageView(image: dateImg)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImplementacionCell", for: indexPath)
            cell.textLabel?.font = UIFont(name: "Aldine721BT-Roman",
                                          size: 15.0)
            if searching {
                cell.textLabel?.text = dataSearch[indexPath.row].name
            } else {
                cell.textLabel?.text = dataSource[indexPath.row].name
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == self.tableView {
            var arrayValues = [Int]()
            
            switch (selectedButton) {
                case buttonCampaign:
                    arrayValues = arrayCampaign
                case buttonMedia:
                    arrayValues = arrayMedia
                default:
                    arrayValues = arrayCampaign
            }
            
            
            var valueSelected: FilterBody
            if searching {
                valueSelected = FilterBody(id: dataSearch[indexPath.row].id, name: dataSearch[indexPath.row].name)
            } else {
                valueSelected = FilterBody(id: dataSource[indexPath.row].id, name: dataSource[indexPath.row].name)
            }
            
            arrayValues.append(valueSelected.id)
            
            if arrayValues.count == 1 {
                selectedButton.setTitle(valueSelected.name, for: .normal)
            } else if arrayValues.count > 1 && arrayValues.count < dataSource.count {
                selectedButton.setTitle("Varios", for: .normal)
            } else if arrayValues.count >= dataSource.count {
                let indexPath = IndexPath(row: 0, section: 0)
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                selectedButton.setTitle("Todos", for: .normal)
            }
            
            switch (selectedButton) {
                case buttonCampaign:
                    arrayCampaign = arrayValues
                case buttonMedia:
                    arrayMedia = arrayValues
                default:
                    arrayCampaign = arrayValues
            }
            
            didSelect = true
            print(arrayValues)
            removeTransparentView()
        }
//        else {
//            showImageView(imageUrl: arrayCampaigns[indexPath.row].imageUrl)
//        }
    }
    
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//
//        if tableView == self.tableView {
//            var arrayValues = [Int]()
//            switch (selectedButton) {
//                case buttonCampaign:
//                    arrayValues = arrayCampaign
//                case buttonMedia:
//                    arrayValues = arrayMedia
//                default:
//                    arrayValues = arrayCampaign
//            }
//            var valueSelected: FilterBody
//            if indexPath.row == 0 {
//                valueSelected = FilterBody(id: -1, name: "Todos")
//            } else {
//                if searching {
//                    valueSelected = FilterBody(id: dataSearch[indexPath.row - 1].id, name: dataSearch[indexPath.row - 1].name)
//                } else {
//                    valueSelected = FilterBody(id: dataSource[indexPath.row - 1].id, name: dataSource[indexPath.row - 1].name)
//                }
//            }
//
//
//            if valueSelected.id == -1 {
//                for section in 0..<tableView.numberOfSections {
//                    for row in 0..<tableView.numberOfRows(inSection: section) {
//                        let indexPath = IndexPath(row: row, section: section)
//                        tableView.deselectRow(at: indexPath, animated: false)
//                    }
//                }
//                arrayValues.removeAll()
//            } else {
//                arrayValues = arrayValues.filter(){$0 != valueSelected.id}
//            }
//
//
//            if arrayValues.count == 1 {
//                let nameLeft: [FilterBody] = dataSource.filter(){$0.id == arrayValues[0]}
//                selectedButton.setTitle(nameLeft[0].name, for: .normal)
//            } else if arrayValues.count > 1 && arrayValues.count < dataSource.count {
//                let indexPath = IndexPath(row: 0, section: 0)
//                tableView.deselectRow(at: indexPath, animated: false)
//                selectedButton.setTitle("Varios", for: .normal)
//            } else if arrayValues.count >= dataSource.count {
//                selectedButton.setTitle("Todos", for: .normal)
//            } else if arrayValues.count == 0 {
//                didSelect = false
//            }
//
//            switch (selectedButton) {
//                case buttonCampaign:
//                    arrayCampaign = arrayValues
//                case buttonMedia:
//                    arrayMedia = arrayValues
//                default:
//                    arrayCampaign = arrayValues
//            }
//            print(arrayValues)
//        }
//    }
    
}

extension ImplementacionVC: UITableViewDelegate {
    
}

extension ImplementacionVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        dataSearch = dataSource.filter({$0.name.uppercased().contains(searchText.uppercased())})
        if searchText != "" {
            searching = true
        } else {
            searching = false
        }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        switch (selectedButton) {
            case buttonMedia:
                arrayMedia.removeAll()
            case buttonCampaign:
                arrayCampaign.removeAll()
            default:
                arrayMedia.removeAll()
        }
    }
}
