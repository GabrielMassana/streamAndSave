//
//  SpinnerView.swift
//  streamAndSave
//
//  Created by GabrielMassana on 07/06/2016.
//  Copyright © 2016 GabrielMassana. All rights reserved.
//

import UIKit

class SpinnerView: UIView {

    //MARK: - Accessors

    lazy var spinner: UIActivityIndicatorView = {
       
        var spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        
        spinner.startAnimating()
        
        return spinner
    }()
    
    //MARK - Init
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        backgroundColor = UIColor.whiteColor()
        
        addSubview(spinner)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
}
