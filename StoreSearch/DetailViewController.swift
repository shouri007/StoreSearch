//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by Shouri on 17/01/16.
//  Copyright © 2016 Shouri. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    required init(coder aDecoder:NSCoder){
        
        super.init(coder: aDecoder)!
        modalPresentationStyle = .Custom
        transitioningDelegate=self
    }
    
    @IBAction func close(){
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension DetailViewController:UIViewControllerTransitioningDelegate{
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        
        return DimmingPresentationController(presentedViewController:presented,presentingViewController: presenting)
    }
}
