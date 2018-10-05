//
//  ServicesController.swift
//  SampleProject
//
//  Created by Paolo Hilario on 5/23/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit

class ServiceProductController: UIViewController {

    @IBOutlet weak var segmentServiceProduct: UISegmentedControl!
    @IBOutlet weak var myContainerSubView: UIView!
    var viewType:String = ""
    var delegateAppointment:ProtocolAddItem? = nil
    var arrayServices       = [Int]()
    var arrayProducts       = [Int]()
    
    lazy var serviceSegmentController: ServiceSegmentController = {
        let storyboard = UIStoryboard(name:"ServicesStoryboard", bundle:Bundle.main)
        var viewController = storyboard.instantiateViewController(withIdentifier: "ServiceSegmentController") as! ServiceSegmentController
        viewController.viewType = viewType
        viewController.delegateAppointment  = delegateAppointment
        self.addViewControllerAsChildViewController(childViewController: viewController)
        return viewController
    }()
    
    lazy var packageSegmentController: PackagesSegmentController = {
        let storyboard = UIStoryboard(name:"ServicesStoryboard", bundle:Bundle.main)
        var viewController = storyboard.instantiateViewController(withIdentifier: "PackagesSegmentController") as! PackagesSegmentController
        viewController.viewType = viewType
        viewController.delegateAppointment = delegateAppointment
        self.addViewControllerAsChildViewController(childViewController: viewController)
        return viewController
    }()

    lazy var productSegmentController: ProductSegmentController = {
        let storyboard = UIStoryboard(name:"ServicesStoryboard", bundle:Bundle.main)
        var viewController = storyboard.instantiateViewController(withIdentifier: "ProductSegmentController") as! ProductSegmentController
        viewController.viewType = viewType
        viewController.delegateAppointment  = delegateAppointment
        self.addViewControllerAsChildViewController(childViewController: viewController)
        return viewController
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        let attr = NSDictionary(object: UIFont(name: "Arial", size: 15.0)!, forKey: kCTFontAttributeName as! NSCopying)
        segmentServiceProduct.setTitleTextAttributes(attr as [NSObject : AnyObject] , for: .normal)
        print("array in service product: \(arrayServices)")
        print("array in service product: \(arrayProducts)")
        setupView()
    }
    
    private func setupView(){
        setupSegmentControl()
        updateView()
    }
    
    private func updateView(){
//        let position = segmentServiceProduct.selectedSegmentIndex
        serviceSegmentController.view.isHidden = !(segmentServiceProduct.selectedSegmentIndex == 0)
        packageSegmentController.view.isHidden = !(segmentServiceProduct.selectedSegmentIndex == 1)
        productSegmentController.view.isHidden = !(segmentServiceProduct.selectedSegmentIndex == 2)
        serviceSegmentController.arrayServices = arrayServices
        productSegmentController.arrayProducts = arrayProducts
    }
    
    private func setupSegmentControl(){
        segmentServiceProduct.removeAllSegments()
        segmentServiceProduct.insertSegment(withTitle: "Services", at: 0, animated: false)
        segmentServiceProduct.insertSegment(withTitle: "Cool Packages", at: 1, animated: false)
        segmentServiceProduct.insertSegment(withTitle: "Products", at: 2, animated: false)
        segmentServiceProduct.addTarget(self, action: #selector(selectionDidChange(sender:)), for: .valueChanged)
        segmentServiceProduct.selectedSegmentIndex = 0
    }
    
    @objc func selectionDidChange(sender:UISegmentedControl){
        updateView()
    }
    
    private func addViewControllerAsChildViewController(childViewController:UIViewController){
        addChildViewController(childViewController)
        myContainerSubView.addSubview(childViewController.view)
        childViewController.view.frame              = myContainerSubView.bounds
        childViewController.view.autoresizingMask   = [.flexibleWidth,.flexibleHeight]
        childViewController.didMove(toParentViewController: self)
    }
    
    private func removeViewControllerAsChildViewController(childViewController:UIViewController){
        childViewController.willMove(toParentViewController: nil)
        childViewController.view.removeFromSuperview()
        childViewController.removeFromParentViewController()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
