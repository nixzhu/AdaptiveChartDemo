//
//  ViewController.swift
//  AdaptiveChartDemo
//
//  Created by NIX on 15/4/4.
//  Copyright (c) 2015年 nixWork. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var appleImageView: UIImageView!

    @IBOutlet weak var chinaImageView: UIImageView!

    @IBOutlet weak var worldImageView: UIImageView!

    @IBOutlet weak var internetImageView: UIImageView!


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

         appleImageView.image = AdaptiveChart(size: appleImageView.bounds.size)
            .setData([
                ("Mac", 50),
                ("iPhone", 400),
                ("WATCH", 100),
                ])
            .setTextFont(UIFont.systemFontOfSize(9))
            .imageWithChartType(.Bar)


        chinaImageView.image = AdaptiveChart(size: chinaImageView.bounds.size)
            .setData([
                ("1960", 174),
                ("1970", 208),
                ("1980", 317),
                ("1990", 665),
                ("2000", 1614),
                ("2010", 4127),
                ])
            .setGraphColor(UIColor.redColor())
            .setTextColor(UIColor.whiteColor())
            .setTextFont(UIFont.systemFontOfSize(10))
            .setShowNumber(true)
            .setNumberType(.Int)
            .setNumberColor(UIColor.greenColor())
            .imageWithChartType(.Line)


        worldImageView.image = AdaptiveChart(size: worldImageView.bounds.size)
            .setData([
                ("1960", 174),
                ("1970", 208),
                ("1980", 317),
                ("1990", 665),
                ("2000年有什么？", 1614),
                ("2010", 4127),
                ])
            .setGraphColor(UIColor.redColor())
            .setTextColor(UIColor.whiteColor())
            .setTextFont(UIFont.systemFontOfSize(10))
            .setShowNumber(true)
            .setNumberType(.Int)
            .setNumberColor(UIColor.greenColor())
            .imageWithChartType(.Line)
    }
}

