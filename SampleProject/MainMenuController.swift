//
//  MainMenuController.swift
//  SampleProject
//
//  Created by Paolo Hilario on 5/21/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit
import SQLite
import Alamofire
import Kingfisher

class MainMenuController: UIViewController,UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource {
 
    @IBOutlet weak var pageControl_carousel: UIPageControl!
    @IBOutlet weak var scrollview_carousel: UIScrollView!
    @IBOutlet weak var collectionViewButton: UICollectionView!
    
    let dbclass         = DatabaseHelper()
    let utilities       = Utilities()
    var SERVER_URL      = ""
    let device          = "IOS"
    let devicetype      = UIDevice.current.modelName
    let dialogUtils     = DialogUtility()
    var structArrayBanner:[ArrayBanner]!
    
    let arrBtnImage = ["a_services","a_giftbox","a_location","a_queuing","a_faq"]
    let arrBtnLabel = ["Services","E-Gift","Branches","Queuing","FAQ's"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionViewButton.delegate   = self
        collectionViewButton.dataSource = self

        let retrieve_ip_address = dbclass.returnIp()
        if(retrieve_ip_address == ""){
            dbclass.deleteIPAddress()
            dbclass.insertIPAddress(url: "https://lbo-testing.azurewebsites.net")
            SERVER_URL =  "https://lbo-testing.azurewebsites.net"
        }
        else{
            SERVER_URL =  self.dbclass.returnIp()
        }
        scrollview_carousel.delegate = self
        getFirstLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    //button navigation for UICollectionViewDataSource protocol
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return arrBtnImage.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionViewButton.dequeueReusableCell(withReuseIdentifier: "menuButtonCell", for: indexPath) as! MenuButtonCollectionViewCell
        cell.imgButtonCell.image = UIImage(named:arrBtnImage[indexPath.row] )
        cell.lblButtonCell.text  = arrBtnLabel[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigateToNextPage(position:indexPath.row)
    }
    
    func navigateToNextPage(position:Int){
        if(position == 0){
            let storyBoard = UIStoryboard(name:"ServicesStoryboard",bundle:nil)
            let serviceVC  = storyBoard.instantiateViewController(withIdentifier: "ServiceProductController") as! ServiceProductController
            self.navigationController?.pushViewController(serviceVC, animated: true)
        }
        if(position == 1){
            let giftUrl = "https://giftaway.ph/laybare?"
            let newurl = URL(string: giftUrl)
            UIApplication.shared.openURL(newurl!)
        }
        if(position == 2){
            
        }
        if(position == 3){
            
        }
        if(position == 4){
            let storyBoard = UIStoryboard(name:"OtherStoryboard",bundle:nil)
            let appointmentVC  = storyBoard.instantiateViewController(withIdentifier: "FAQController") as! FAQController
            self.navigationController?.pushViewController(appointmentVC, animated: true)
            self.tabBarController?.tabBar.isHidden = true
        }
    
    }
    
    func getFirstLoad(){
        
        self.dialogUtils.showActivityIndicator(self.view)
        var deviceUniqueID = "";
        let token          = utilities.getUserToken()
        guard var appVersion = try Bundle.main.infoDictionary?["CFBundleShortVersionString"] else { return }
        if let getDeviceID =  UIDevice.current.identifierForVendor?.uuidString{
            deviceUniqueID = getDeviceID
        }
        else{
            deviceUniqueID = "N/A"
        }
        var myUrlString = SERVER_URL+"/api/mobile/getAppVersion/\(appVersion)/\(device)/\(devicetype)/\(deviceUniqueID)?token=\(token)";
        print(myUrlString)
        // Alamofire 4
        let requestParams: Parameters = ["":""]
        Alamofire.request(myUrlString, method: .get, parameters: requestParams)
            .responseJSON { response in
                do{
                    guard let statusCode   = try response.response?.statusCode else { return }
                    let responseError    = response.error?.localizedDescription
                    if(statusCode == 200 || statusCode == 201){
                        if response.result.value != nil{
                            let dataResponse              = response.data
                            let objectResponse            = try JSONDecoder().decode(AppFirstLoadVersion.self, from: dataResponse!)
                            let ifUpdated:Bool            = objectResponse.ifUpdated!
                            let isValidToken:Bool         = objectResponse.isValidToken!
                            
                            if(isValidToken == false){
                               self.loadMainMenu()
                            }
                            else{
                                if (isValidToken == true){
                                    let objectProfileAccount    = objectResponse.arrayProfile
                                    let encodedObjectProfile    = try JSONEncoder().encode(objectProfileAccount)
                                    let resultObjectString      = String(data: encodedObjectProfile, encoding: .utf8)!
                                    let date_updated            = self.utilities.getCurrentDateTime(ifDateOrTime: "datetime")
                                    print("Date Updated: \(date_updated)")
                                    if(self.dbclass.countUserAccount() > 0){
                                        let user_id     = objectProfileAccount?.id
                                        let user_name   = objectProfileAccount?.username
                                        self.dbclass.updateUserProfile(id: user_id!, name: user_name!, token: token, object_data: resultObjectString, date_updated: date_updated)
                                    }
                                   self.loadMainMenu()
                                }
                                else{
                                    self.loadMainMenu()
                                }
                            }
                        }
                        print("Success \(statusCode)")
                        return
                        
                    }
                    if(statusCode == 401){
                        print("Token Expired")
                        //token expired
                        self.loadMainMenu()
                    }
                    else{
                        print("Error else : \(String(describing: responseError))")
                        //alert error
                        self.loadMainMenu()
                    }
                }
                catch{
                    print("Error: \(error)")
                    self.loadMainMenu()
                }
        }
        
    }
    
    
    func loadMainMenu(){
        
        let local_version_carousel      = utilities.getCarouselVersion()
        let local_version_commercial    = utilities.getCommercialVersion()
        let local_version_service       = utilities.getServiceVersion()
        let local_version_package       = utilities.getPackageVersion()
        let local_version_product       = utilities.getProductVersion()
        let local_version_branch        = utilities.getBranchVersion()
        
         // Alamofire 4
        var myUrlString = SERVER_URL+"/api/mobile/getFirstLoadDetails/\(local_version_carousel)/\(local_version_commercial)/\(local_version_service)/\(local_version_package)/\(local_version_product)/\(local_version_branch)";
        let requestParams: Parameters = ["":""]
        
        Alamofire.request(myUrlString, method: .get, parameters: requestParams)
            .responseJSON { response in
                do{
                    guard let statusCode   = try response.response?.statusCode else { return }
                    let responseError    = response.error?.localizedDescription
                    if(statusCode == 200){
                       
                    if let responseJSON = response.data { // deserialized already
                        do {
                            // Decode data to object
                            var version_banner      = 0.0
                            var version_branches    = 0.0
                            var version_commercial  = 0.0
                            var version_services    = 0.0
                            var version_packages    = 0.0
                            var version_products    = 0.0
                            
                            let jsonDecoder     = JSONDecoder()
                            let responseDecoded = try jsonDecoder.decode(MainMenuResponse.self, from: responseJSON)
                            
                            if let versions = responseDecoded.versions {
                                
                                version_banner      = versions.version_banner!
                                version_branches    = versions.version_branches!
                                version_commercial  = versions.version_commercial!
                                version_services    = versions.version_services!
                                version_packages    = versions.version_packages!
                                version_products    = versions.version_products!
                    
                                if let arrayCarousel = responseDecoded.arrayBanner{
                                    
                                    if(version_banner > local_version_carousel ){
                                        let encoded             = try JSONEncoder().encode(arrayCarousel)
                                        let stringJSONBanner    = String(decoding: encoded, as: UTF8.self)
                                        self.dbclass.deleteCarousel()
                                        self.dbclass.insertCarousel(version_no: local_version_carousel,arrayCarousel: stringJSONBanner)
                                    }
                                }
                                
                                if let arrayServices       = responseDecoded.arrayServices{
                                    if(version_services > local_version_service){
                                        let encoded             = try JSONEncoder().encode(arrayServices)
                                        let stringJSONService    = String(decoding: encoded, as: UTF8.self)
                                        self.dbclass.deleteServices()
                                        self.dbclass.insertServices(insert_version: local_version_service, insert_array: stringJSONService)
                                    }
                                }
                                if let arrayPackage        = responseDecoded.arrayPackage{
                                    if(version_packages > local_version_package){
                                        let encoded              = try JSONEncoder().encode(arrayPackage)
                                        let stringJSONPackage    = String(decoding: encoded, as: UTF8.self)
                                        self.dbclass.deletePackages()
                                        self.dbclass.insertPackages(insert_version: local_version_package, insert_array: stringJSONPackage)
                                    }
                                }
                                if let arrayProducts       = responseDecoded.arrayProducts{
                                    if(version_products > local_version_product){
                                        let encoded              = try JSONEncoder().encode(arrayProducts)
                                        let stringJSONProduct    = String(decoding: encoded, as: UTF8.self)
                                        self.dbclass.deleteProducts()
                                        self.dbclass.insertProducts(insert_version: local_version_product, insert_array: stringJSONProduct)
                                    }
                                }
                                if let arrayBranch         = responseDecoded.arrayBranch{
                                    if(version_branches > local_version_branch){
                                        let encoded              = try JSONEncoder().encode(arrayBranch)
                                        let stringJSONBranch     = String(decoding: encoded, as: UTF8.self)
                                        self.dbclass.deleteBranches()
                                        self.dbclass.insertBranches(insert_version: local_version_branch, insert_array:stringJSONBranch)
                                    }
                                }
                                if let arrayCommercial     = responseDecoded.arrayCommercial{
                                    if(version_commercial > local_version_commercial ){
                                        let encoded              = try JSONEncoder().encode(arrayCommercial)
                                        let stringJSONCommercial = String(decoding: encoded, as: UTF8.self)
                                        self.dbclass.deleteCommercial()
                                        self.dbclass.insertCommercial(insert_version: local_version_commercial, insert_array: stringJSONCommercial)
                                    }
                                }
                            }
                        }
                        catch {
                            print(error)
                        }
                        self.dialogUtils.hideActivityIndicator(self.view)
                        self.initiateBanner()
                    }
                        
                }
                if(statusCode == 401){
                    print("Token Expired")
                    self.dialogUtils.hideActivityIndicator(self.view)
                    self.initiateBanner()
                }
                if(responseError != nil){
                    print("Error response: \(responseError)")
                    self.dialogUtils.hideActivityIndicator(self.view)
                    self.initiateBanner()
                }
            }
            catch{
                print("Error1: \(response.error)")
                self.dialogUtils.hideActivityIndicator(self.view)
                self.initiateBanner()
            }
        }
    }
    
    func initiateBanner()  {
        let carousel_tbl = dbclass.carousel_tbl
        do {
            if let queryBanner = try dbclass.db?.pluck(carousel_tbl){
                let arrayBannerData     = queryBanner[dbclass.carousel_array]
                let jsonData            = arrayBannerData.data(using: .utf8)
                structArrayBanner       = try JSONDecoder().decode([ArrayBanner].self, from: jsonData!)
                var x = 0
                pageControl_carousel.numberOfPages = Int(structArrayBanner.count)
                
                for row in structArrayBanner{
                    
                    let imgSrc              = row.image!
                    let url                 = URL(string:SERVER_URL+"/images/ads/\(imgSrc)")
                    let imageView           = UIImageView()
                    imageView.kf.setImage(with: url)
                    imageView.contentMode   = .scaleToFill
                    let xPosition           = self.view.frame.width * CGFloat(x)
                    imageView.frame         = CGRect(x: xPosition, y: 0, width: self.scrollview_carousel.frame.width, height: self.scrollview_carousel.frame.height)
                    scrollview_carousel.contentSize.width = scrollview_carousel.frame.width * CGFloat(x + 1)
                    scrollview_carousel.addSubview(imageView)
                    x+=1
                }
            }
        }
        catch {
            print(error)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl_carousel.currentPage = Int(scrollview_carousel.contentOffset.x / CGFloat(view.frame.width))
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Loading")
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    
    
}
