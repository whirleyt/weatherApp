//
//  TableViewController.swift
//  HW3
//
//  Edited by Tara Whirley on 10/11/23.
//

import UIKit

class myCustomCell: UITableViewCell {
    
    @IBOutlet weak var cities: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var temperatures: UILabel!
    @IBOutlet weak var state: UILabel!
    
}

class TableViewController: UITableViewController {

    struct weatherItem: Codable {
        let location: location
        let current: current
    }

    struct current: Codable {
        let temp_f: Double
        let wind_mph: Double
        let precip_in, humidity: Double
        let condition: Condition
    }

    struct Condition: Codable {
        let text: String
        let icon: String?
    }

    struct location: Codable {
        let name, region, country: String
    }
    
    var allWeather:[weatherItem]=[];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        navigationItem.rightBarButtonItem = editButtonItem
        navigationController?.setNavigationBarHidden(false, animated: false)
        let userDefaults = UserDefaults.standard
        if let savedData = userDefaults.data(forKey: "weather_data"),
            let decodedData = try? JSONDecoder().decode([weatherItem].self, from: savedData) {
            allWeather = decodedData
        } else {
            print("No locally stored data found")
        }
        
        self.getAllData(for: "New York")
        self.getAllData(for: "Jersey City")
        self.getAllData(for: "Conneticut")
        self.getAllData(for: "Dallas")
        self.getAllData(for: "Austin")
        self.getAllData(for: "Stanford")
        self.getAllData(for: "San Jose")
        self.getAllData(for: "Washington DC")
        self.getAllData(for: "Boston")
        self.getAllData(for: "Miami")
        self.getAllData(for: "Orlando")
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell", for: indexPath) as! myCustomCell

           let weather = allWeather[indexPath.row]
           cell.cities.text = weather.location.name
           cell.temperatures.text = "\(weather.current.temp_f)°F"
           cell.state.text = weather.current.condition.text
           if let iconURLString = weather.current.condition.icon {
               var imageUrl: URL
               if iconURLString.hasPrefix("http") {
                   imageUrl = URL(string: iconURLString)!
               } else {
                   let baseUrlString = "https:"
                   let completeIconURLString = baseUrlString + iconURLString
                   imageUrl = URL(string: completeIconURLString)!
               }
               URLSession.shared.dataTask(with: imageUrl) { (data, _, error) in
                   if let data = data, let image = UIImage(data: data) {
                       DispatchQueue.main.async {
                           cell.icon.image = image
                       }
                   }
               }.resume()
           }
           return cell
    }

    
    override func tableView(_ tableView:UITableView, titleForHeaderInSection section: Int)  -> String? {
        return "Weather"
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            allWeather.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let movedWeather = allWeather.remove(at: fromIndexPath.row)
        allWeather.insert(movedWeather, at: to.row)
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
               
            } else {
                if !(presentedViewController?.isBeingDismissed ?? true){
                    performSegue(withIdentifier: "detailsSegue", sender: indexPath)
                }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailsSegue" {
            let destVC = segue.destination as! detailViewController
            let selectedRow = tableView.indexPathForSelectedRow?.row
            destVC.city = "City: " + allWeather[selectedRow!].location.name
            destVC.temp = "Temperature: " + "\(allWeather[selectedRow!].current.temp_f)°F"
            destVC.condition = "Condition: " + allWeather[selectedRow!].current.condition.text
            destVC.wind = "Wind: " + String(allWeather[selectedRow!].current.wind_mph) + "mph"
            destVC.precipitation = "Precipitation: " + String(allWeather[selectedRow!].current.precip_in) + "in"
            destVC.humidity = "Humidity: " + String(allWeather[selectedRow!].current.humidity) + "%"
        }
    }
    
    func getAllData(for city: String) {
        let headers = [
            "X-RapidAPI-Key": "88d9ccd54emsh1e8b5fbc5c51193p1ad1c6jsn690b0a4532e0",
            "X-RapidAPI-Host": "weatherapi-com.p.rapidapi.com"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://weatherapi-com.p.rapidapi.com/current.json?q=\(city)")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        func getAllData(for city: String) {
            let dataTask = session.dataTask(with: request as URLRequest) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                        self.showErrorAlert(message: error.localizedDescription)
                        return
                    }
                    do {
                        guard let jsonData = data else {
                            print("No data")
                            return
                        }
                        if let jsonString = String(data: jsonData, encoding: .utf8) {
                            print("Received JSON: \(jsonString)")
                        }
                        
                        if let jsonDictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                            if let locationDictionary = jsonDictionary["location"] as? [String: Any],
                               let currentDictionary = jsonDictionary["current"] as? [String: Any] {
                                let locationData = try JSONSerialization.data(withJSONObject: locationDictionary)
                                let currentData = try JSONSerialization.data(withJSONObject: currentDictionary)
                                
                                let location = try JSONDecoder().decode(location.self, from: locationData)
                                let current = try JSONDecoder().decode(current.self, from: currentData)
                                
                                let weatherItem = weatherItem(location: location, current: current)
                                
                                self.allWeather.append(weatherItem);
                                let userDefaults = UserDefaults.standard
                                
                                if let jsonData = try? JSONEncoder().encode(self.allWeather) {
                                    userDefaults.set(jsonData, forKey: "weather_data")
                                }
                            }
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    } catch {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true)
                        }
                    }
                }
            }
            dataTask.resume()
        }
    }
    
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}
