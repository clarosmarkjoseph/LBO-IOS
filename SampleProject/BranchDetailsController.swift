//
//  BranchDetailsController.swift
//  SampleProject
//
//  Created by Paolo Hilario on 7/11/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit
//import Alamofire
import Kingfisher

class BranchDetailsController: UIViewController,UIScrollViewDelegate {

    @IBOutlet var uiviewBody: UIView!
    @IBOutlet var segmentBranch: UISegmentedControl!
    @IBOutlet var pageControlGallery: UIPageControl!
    @IBOutlet var scrollviewGallery: UIScrollView!
    @IBOutlet var uiviewContent: UIView!
    @IBOutlet var lblBranchOtherDetails: UILabel!
    var objectBranch:ArrayBranch?   = nil
    let utilities                   = Utilities()
    let dbclass                     = DatabaseHelper()
    var SERVER_URL                  = ""
    var offset                      = 0
    var arrayBranchCarousel         = [String]()
    var objectRating:BranchObjectRatingResult? = nil
    var stringDistance              = ""
    
    lazy var branchInfoController: BranchInfoController = {
        let storyboard      = UIStoryboard(name:"BranchLocationStoryboard", bundle:Bundle.main)
        var viewController  = storyboard.instantiateViewController(withIdentifier: "BranchInfoController") as! BranchInfoController
        viewController.objectBranch = objectBranch
        self.addViewControllerAsChildViewController(childViewController: viewController)
        return viewController
    }()
    
    lazy var branchSchedController: BranchScheduleController = {
        let storyboard      = UIStoryboard(name:"BranchLocationStoryboard", bundle:Bundle.main)
        var viewController  = storyboard.instantiateViewController(withIdentifier: "BranchScheduleController") as! BranchScheduleController
        viewController.objectBranch = objectBranch
        viewController.isMainView   = false
        viewController.parentView   = self.view
        self.addViewControllerAsChildViewController(childViewController: viewController)
        return viewController
    }()
    
    lazy var branchRatingController: BranchRatingController = {
        let storyboard      = UIStoryboard(name:"BranchLocationStoryboard", bundle:Bundle.main)
        var viewController  = storyboard.instantiateViewController(withIdentifier: "BranchRatingController") as! BranchRatingController
        viewController.objectBranch     = objectBranch
        viewController.objectRating     = objectRating
        self.addViewControllerAsChildViewController(childViewController: viewController)
        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SERVER_URL = dbclass.returnIp()
        
        setupView()
        loadGallery()
    }
    
    private func setupView(){
        updateView()
    }
    
    private func updateView(){
        branchInfoController.view.isHidden      = !(segmentBranch.selectedSegmentIndex == 0)
        branchSchedController.view.isHidden     = !(segmentBranch.selectedSegmentIndex == 1)
        branchRatingController.view.isHidden    = !(segmentBranch.selectedSegmentIndex == 2)
    }

    @IBAction func segmentClicked(_ sender: UISegmentedControl) {
        updateView()
    }
    
    private func addViewControllerAsChildViewController(childViewController:UIViewController){
        addChildViewController(childViewController)
        uiviewContent.addSubview(childViewController.view)
        childViewController.view.frame              = uiviewContent.bounds
        childViewController.view.autoresizingMask   = [.flexibleWidth,.flexibleHeight]
        childViewController.didMove(toParentViewController: self)
    }
    
    private func removeViewControllerAsChildViewController(childViewController:UIViewController){
        childViewController.willMove(toParentViewController: nil)
        childViewController.view.removeFromSuperview()
        childViewController.removeFromParentViewController()
    }
    
    
    func loadGallery(){
        do{
        
            self.navigationItem.title    = objectBranch?.branch_name?.capitalized ?? "Lay Bare Branch"
            lblBranchOtherDetails.text   = "\(stringDistance ) away from your current location"
            let pictures        = objectBranch?.branch_pictures
            let pictureData     = pictures?.data(using: .utf8)
            arrayBranchCarousel = try JSONDecoder().decode([String].self, from: pictureData!)
            
            if(arrayBranchCarousel.count > 0){
                pageControlGallery.numberOfPages = arrayBranchCarousel.count
                var x = 0
                for row in arrayBranchCarousel{
                    let imageView           = UIImageView()
                    let imgSrc              = row
                    let url   = URL(string:SERVER_URL+"/images/branches/\(imgSrc)")
                    imageView.kf.setImage(with: url)
                    imageView.contentMode   = .scaleToFill
                    let xPosition           = self.view.frame.width * CGFloat(x)
                    imageView.frame         = CGRect(x: xPosition, y: 0, width: self.scrollviewGallery.frame.width, height: self.scrollviewGallery.frame.height)
                    scrollviewGallery.contentSize.width = scrollviewGallery.frame.width * CGFloat(x + 1)
                    scrollviewGallery.addSubview(imageView)
                    x+=1
                }
            }
            else{
                pageControlGallery.numberOfPages    = 1
                let imageView                       = UIImageView()
                imageView.image         = UIImage(named: "app_logo")
                imageView.contentMode   = .scaleToFill
                let xPosition           = self.view.frame.width * CGFloat(0)
                imageView.frame         = CGRect(x: xPosition, y: 0, width: self.scrollviewGallery.frame.width, height: self.scrollviewGallery.frame.height)
                scrollviewGallery.contentSize.width = scrollviewGallery.frame.width * CGFloat(0 + 1)
                scrollviewGallery.addSubview(imageView)
            }
        }
        catch{
            print("ERROR: \(error)")
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("SCROLLED: \(Int(scrollviewGallery.contentOffset.x / CGFloat(view.frame.width)))")
        pageControlGallery.currentPage = Int(scrollviewGallery.contentOffset.x / CGFloat(view.frame.width))
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    

    

}
