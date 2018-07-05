//
//  PremiereCardPreviewController.swift
//  SampleProject
//
//  Created by Paolo Hilario on 6/29/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit

class PremiereCardPageviewController: UIPageViewController,UIPageViewControllerDataSource,UIPageViewControllerDelegate {
    
    var positionIndex = 0
    lazy var VCArray: [UIViewController] = {
        return [
            self.VCInstance(name: "PremiereCardPreviewController", positionIndex: 0),
            self.VCInstance(name: "PremiereCardPreviewController",positionIndex: 1)
        ]
    }()
    
    private func VCInstance(name:String,positionIndex:Int) -> UIViewController{
        
        let storyboard     = UIStoryboard(name: "PremiereStoryboard", bundle: nil)
        let myVC           = storyboard.instantiateViewController(withIdentifier: name) as! PremiereCardPreviewController
        myVC.positionIndex = positionIndex
        return myVC
    }
    
    let utilities      = Utilities()
    let dbclass        = DatabaseHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate   = self
        if let firstVC  = VCArray.first{
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
        
    }

    override var shouldAutorotate: Bool{
        return true
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.landscapeLeft, andRotateTo: UIInterfaceOrientation.landscapeRight)
    }
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
    }
    
   
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for view in self.view.subviews{
            if view is UIScrollView{
                view.frame = UIScreen.main.bounds
            }
            else if view is UIPageControl{
                view.backgroundColor = UIColor.clear
            }
        }
    }
    
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = VCArray.index(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else{
            return VCArray.last
        }
        guard VCArray.count > previousIndex else{
            return nil
        }
        let vc              = VCArray[previousIndex]
        return vc
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = VCArray.index(of: viewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < VCArray.count else{
            return VCArray.first
        }
        
        guard VCArray.count > nextIndex else{
            return nil
        }
        let vc              = VCArray[nextIndex]
        return vc
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    }

    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        print("Count ARRAY: \(VCArray.count)")
        return VCArray.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
           
            let firstViewControllerIndex = VCArray.index(of: firstViewController) else{
            return 0
        }
        positionIndex = firstViewControllerIndex
        
        return firstViewControllerIndex
    }
    
    
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    

}



