//
//  ViewController.swift
//  Document-Management
//
//  Created by Kaichi Momose on 2018/01/19.
//  Copyright © 2018 Kaichi Momose. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let path = Bundle.main.path(forResource: "collection-resource", ofType: ".json")
        if let path = path {
            let url = URL(fileURLWithPath: path)
            let content = try? Data(content)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

