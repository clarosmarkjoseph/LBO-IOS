//
//  BranchLocationController.swift
//  SampleProject
//
//  Created by Paolo Hilario on 7/9/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit
import GoogleMaps


class BranchLocationController: UIViewController,CLLocationManagerDelegate,UITextFieldDelegate,ProtocolLocationButton,ProtocolBranch {

    @IBOutlet var txtSearchBranch: UITextField!
    @IBOutlet var txtFilterBranch: UITextField!
    @IBOutlet var mapView: GMSMapView!
    
    let utilities               = Utilities()
    let dbclass                 = DatabaseHelper()
    var currentLat              = 0.0
    var currentLng              = 0.0
    private let locationManager = CLLocationManager()
    let locationMgr             = CLLocationManager()
    var currentLocation         = CLLocation()
    var ifLastLocation          = false
    var arrayBranches           = [ArrayBranch]()
    var arrayNearestBranch      = [ArrayBranch]()
    var ifNearest               = false
    let dialogUtil              = DialogUtility()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate         = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    func loadViewMap(){
        
        if(ifLastLocation == true){
            currentLat      = currentLocation.coordinate.latitude
            currentLng      = currentLocation.coordinate.longitude
            let camera      = GMSCameraPosition.camera(withLatitude: currentLat, longitude: currentLng, zoom: 14.0)
            mapView.camera  = camera
            
            txtFilterBranch.text     = "All Branches"
            txtSearchBranch.addTarget(self, action: #selector(searchBranches), for: UIControlEvents.editingDidBegin)
            txtFilterBranch.addTarget(self, action: #selector(selectOption), for: UIControlEvents.editingDidBegin)
            markCurrentLocation()
            self.loadBranches()
        }
    }
    
    func markCurrentLocation(){
        // Creates a marker in the center of the map.
        let marker      = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude:currentLat, longitude:currentLng)
        marker.title    = "My Current Location"
        marker.snippet  = ""
        marker.map      = mapView
        
        
    }
    
    func loadBranches(){
        if(arrayBranches.count <= 0){
            do{
                let stringBranches = dbclass.returnBranches()
                let jsonData       = stringBranches.data(using: .utf8)
                let jsonDecoded      = try JSONDecoder().decode([ArrayBranch].self, from: jsonData!)
                for rows in jsonDecoded{
                    
                    var objectBranch    = rows
                    let lat             = objectBranch.map_coordinates?.lat
                    let lng             = objectBranch.map_coordinates?.long ?? 0.0
                    let distance        = utilities.getDistanceOfLocation(currentLat: currentLat, currentLng: currentLng, destinationLat: Double(lat!), destinationLng: Double(lng))
                    
                    objectBranch.estimated_distance     = distance
                    objectBranch.estimated_travel_time  = "0 min"
                    
                    if(distance <= 5.0){
                        arrayNearestBranch.append(objectBranch)
                    }
                    arrayBranches.append(objectBranch)
                }
                generateMarkers()
            }
            catch{
                print("ERROR loading: \(error)")
            }
        }
        else{
             generateMarkers()
        }
    }
 
    func generateMarkers(){
        
        arrayBranches = arrayBranches.sorted(by: {
            ($0.estimated_distance ?? 0) < ($1.estimated_distance ?? 0)
        })

        arrayNearestBranch = arrayNearestBranch.sorted(by: {
            ($0.estimated_distance ?? 0) < ($1.estimated_distance ?? 0)
        })
        var arraySelected = [ArrayBranch]()
        if(ifNearest == true){
            arraySelected = arrayNearestBranch
        }
        else{
            arraySelected = arrayBranches
        }
       
        var rowPosition = 0
        for rows in arraySelected{
            
            let branch_name     = rows.branch_name!
            let branch_address  = rows.branch_address!
            let lat             = rows.map_coordinates?.lat
            let lng             = rows.map_coordinates?.long ?? 0.0
            let marker                  = GMSMarker()
            marker.position             = CLLocationCoordinate2D(latitude:CLLocationDegrees(lat!), longitude:CLLocationDegrees(lng))
            marker.title                = branch_name
            marker.snippet              = branch_address
            marker.icon                 = UIImage(named: "a_pointer")
            marker.userData             = rowPosition
            marker.map                  = mapView
            rowPosition+=1
            print("Name & position: \(branch_name) - \(rowPosition)")
        }
    }
    
    @objc func searchBranches(){
        txtSearchBranch.resignFirstResponder()
        txtFilterBranch.resignFirstResponder()
        var selectedArray = [ArrayBranch]()
        
        if ifNearest == true{
            selectedArray = arrayNearestBranch
        }
        else{
            selectedArray = arrayBranches
        }
        
        let viewController = UIStoryboard(name: "OtherStoryboard", bundle: nil).instantiateViewController(withIdentifier: "BranchController") as? BranchController
        viewController?.ifAppointment   = false
        viewController?.delegate        = self
        viewController?.ifLocation      = true
        viewController?.arrayBranches   = selectedArray
        present(viewController!, animated: true,completion: nil)
    }
    
    
    @objc func selectOption(){
        
        txtSearchBranch.resignFirstResponder()
        txtFilterBranch.resignFirstResponder()
        let alertView = UIAlertController(title: "Filter Branch", message: "How do you want to show branches ", preferredStyle: .actionSheet)
        
        let btnAll = UIAlertAction(title: "All Branches", style: .default) { (action) in
            self.mapView.clear()
            self.txtFilterBranch.text = "All Branches"
            self.ifNearest = false
            self.markCurrentLocation()
            self.generateMarkers()
        }
        let btnNearest = UIAlertAction(title: "Nearest Branches", style: .default) { (action) in
            self.mapView.clear()
            self.txtFilterBranch.text = "Nearest Branches (5 km)"
            self.ifNearest = true
            self.markCurrentLocation()
            self.generateMarkers()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        alertView.addAction(btnAll)
        alertView.addAction(btnNearest)
        alertView.addAction(cancel)
        present(alertView,animated: true,completion: nil)
    }
    
    
    
    func setBranch(selectedBranch: String, selectedBranchID: Int, objectSelectedBranch: ArrayBranch,arrayIndex: Int) {
        let lat         = objectSelectedBranch.map_coordinates?.lat ?? 0.0
        let lng         = objectSelectedBranch.map_coordinates?.long ?? 0.0
        let camera      = GMSCameraPosition.camera(withLatitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lng), zoom: 14.0)
        mapView.camera  = camera
        showBranchDetails(userIndex: arrayIndex)
    }
    
    func getIndexFromMarker(marker:GMSMarker){
        let userIndex           = marker.userData as! Int
        showBranchDetails(userIndex: userIndex)
    }
    
    func showBranchDetails(userIndex:Int){
        
        var arraySelected       = [ArrayBranch]()
        if(ifNearest == true){
            arraySelected = arrayNearestBranch
        }
        else{
            arraySelected = arrayBranches
        }
        
        txtSearchBranch.text    = arraySelected[userIndex].branch_name
        let default_distance    = arraySelected[userIndex].estimated_distance ?? 0.0
        let default_duration    = arraySelected[userIndex].estimated_travel_time ?? "0 min"
        let viewController      = UIStoryboard(name: "DialogStoryboard", bundle: nil).instantiateViewController(withIdentifier: "BranchCustomWindowInfo") as? BranchCustomWindowInfo
        viewController?.objectBranchDetails     = arraySelected[userIndex]
        viewController?.current_lat             = currentLat
        viewController?.current_lng             = currentLng
        viewController?.estimated_distance      = default_distance
        viewController?.estimated_duration      = default_duration
        viewController?.delegateButton          = self
        viewController?.index                   = userIndex
        viewController?.modalTransitionStyle    = .crossDissolve
        present(viewController!, animated: true,completion: nil)
        viewController?.popoverPresentationController?.sourceView = view
        viewController?.popoverPresentationController?.sourceRect = view.frame
        
    }
    
    func buttonPressed(objectRating:BranchObjectRatingResult,index:Int,distance:Double,duration:String) {
     
        
        let storyBoard = UIStoryboard(name:"BranchLocationStoryboard",bundle:nil)
        let viewController  = storyBoard.instantiateViewController(withIdentifier: "BranchDetailsController") as! BranchDetailsController
        let strincDistance      = utilities.convertDistanceToString(distance: distance)
        var arraySelected       = [ArrayBranch]()
        
        if(ifNearest == true){
            arraySelected = arrayNearestBranch
        }
        else{
            arraySelected = arrayBranches
        }
        arraySelected[index].estimated_distance     = Double(strincDistance)
        arraySelected[index].estimated_travel_time  = duration
        viewController.objectBranch                 = arraySelected[index]
        viewController.objectRating                 = objectRating
        viewController.stringDistance               = strincDistance
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }

    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // 3
        if status == .notDetermined {
            locationMgr.requestWhenInUseAuthorization()
            return
        }
        if status == .denied || status == .restricted {
            let alertView   = UIAlertController(title: "Location Services Disabled", message: "Please enable Location Services in Settings", preferredStyle: .alert)
            
            let cancel      = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                self.navigationController?.popViewController(animated: true)
            }
            
            let confirm = UIAlertAction(title: "Check Permission", style: .default) { (action) in
                if let url = URL(string: UIApplicationOpenSettingsURLString) {
                    // If general location settings are disabled then open general location settings
                    UIApplication.shared.openURL(url)
                }
            }
            alertView.addAction(confirm)
            alertView.addAction(cancel)
            present(alertView,animated: true,completion: nil)
        }
        else{
            self.dialogUtil.showActivityIndicator(self.view)
            locationManager.startUpdatingLocation()
            mapView.isMyLocationEnabled         = true
            mapView.settings.myLocationButton   = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last!
        ifLastLocation  = true
        locationManager.stopUpdatingLocation()
        loadViewMap()
        self.dialogUtil.hideActivityIndicator(self.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}




// extension for GMSMapViewDelegate
extension BranchLocationController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if(marker.userData != nil){
            getIndexFromMarker(marker: marker)
        }
        return false
    }
    
    
}
