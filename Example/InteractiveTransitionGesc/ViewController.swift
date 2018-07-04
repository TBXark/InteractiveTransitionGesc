//
//  ViewController.swift
//  InteractiveTransitionGesc
//
//  Created by TBXark on 07/04/2018.
//  Copyright (c) 2018 TBXark. All rights reserved.
//

import UIKit
import InteractiveTransitionGesc

class ViewController: UIViewController, UINavigationControllerDelegate {

    var customInteractor: Interactor?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return customInteractor
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            self.customInteractor = Interactor(attachTo: toVC.navigationController!, actionKind: .pop)
            return nil
        default:
            return DismissAnimator(direction: self.customInteractor?.direction ?? .horizontal, duration: 0.5)
        }
    }
}

class TargetViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}


