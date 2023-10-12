//
//  detailViewController.swift
//  HW3
//
//  Edited by Tara Whirley on 10/11/23.
//

import UIKit

class detailViewController: UIViewController {
 
    @IBOutlet weak var cities: UILabel!
    @IBOutlet weak var temperatures: UILabel!
    @IBOutlet weak var state: UILabel!
    @IBOutlet weak var wind_mphs: UILabel!
    @IBOutlet weak var precip_ins: UILabel!
    @IBOutlet weak var humidities: UILabel!
    
    var city: String = ""
    var temp: String = ""
    var condition: String = ""
    var wind: String = ""
    var precipitation: String = ""
    var humidity: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cities.text = city
        self.temperatures.text = temp
        self.state.text = condition
        self.precip_ins.text = precipitation
        self.wind_mphs.text = wind
        self.humidities.text = humidity
    }
}
