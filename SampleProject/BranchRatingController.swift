//
//  BranchRating.swift
//  SampleProject
//
//  Created by Paolo Hilario on 7/11/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit
import Charts
import Cosmos
import Alamofire
import Kingfisher

class BranchRatingController: UITableViewController,ChartViewDelegate {
    
    @IBOutlet var barChartRating: HorizontalBarChartView!
    @IBOutlet var lblAverageRating: UILabel!
    @IBOutlet var lblTotalReview: UILabel!
    @IBOutlet var ratingBar: CosmosView!
    @IBOutlet var tblRating: UITableView!
    
    weak var axisFormatDelegate: IAxisValueFormatter?
    
    let dialogUtil                  = DialogUtility()
    var objectBranch:ArrayBranch?   = nil
   
    var arrayRatingScale    = [String]()
    var arrayRatingValue    = [Double]()
    var isLoaded            = false
    let utilities           = Utilities()
    let dbclass             = DatabaseHelper()
    var SERVER_URL          = ""
    
    var ratingOffset        = 0
    var distance            = 0.0
    var duration            = "0 min"
    var branch_id           = 0
    
    var objectRating:BranchObjectRatingResult?  = nil
    var arrayReviews:[ArrayReviewStruct]        =  [ArrayReviewStruct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SERVER_URL                          = dbclass.returnIp()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if isLoaded == false{
            isLoaded         = true
            loadReviews()
        }
    }
    
    func loadReviews(){
        
        branch_id        = objectBranch?.id ?? 0
        distance         = objectRating?.distance ?? 0.0
        duration         = objectRating?.duration ?? "0 mins"
        ratingOffset     = objectRating?.offset ?? 0
        arrayReviews     = objectRating?.arrayReview ?? [ArrayReviewStruct]()
        
        arrayRatingScale = ["1s★", "2s★", "3s★", "4s★", "5s★"]
        arrayRatingValue = getAverageRating()
        
        let averageRating       = objectRating?.totalRatings ?? 0.0
        let averageReview       = objectRating?.totalReviews ?? 0
        lblTotalReview.text     = "\(averageReview) review(s)"
        lblAverageRating.text   = "\(averageRating)"
        ratingBar.rating        = averageRating
        
        if(arrayRatingValue.count > 0){
             setChart(dataPoints: arrayRatingScale, values: arrayRatingValue)
        }
        else{
            barChartRating.noDataText           = "No Review(s) available"
            barChartRating.noDataTextColor      = #colorLiteral(red: 0.4666666667, green: 0.2549019608, blue: 0.003921568627, alpha: 1)
        }
        self.tblRating.reloadData()
    }
    
    func getMoreReviews(){
        
        let stringURL       = SERVER_URL+"/api/mobile/getBranchRatings"
        let requestParams   = [
            "branch_id":"\(branch_id)",
            "offset":ratingOffset,
            "getAllDetails":"true"
            ] as [String : Any]
        let myURL = URL(string: stringURL)
        
        Alamofire.request(myURL!, method: .post, parameters: requestParams)
            .responseJSON { response in
                do{
                   
                    guard let statusCode   = try response.response?.statusCode else {
                        self.dialogUtil.hideActivityIndicator(self.view)
                        self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                        return
                    }
                    
                    if let responseJSONData = response.data{
                        self.dialogUtil.hideActivityIndicator(self.view)
                        if(statusCode == 200 || statusCode == 201){
                            let jsonDecodable = try JSONDecoder().decode(BranchObjectRatingResult.self, from: responseJSONData)
                            self.ratingOffset+=jsonDecodable.offset ?? 0
                            let moreReview = jsonDecodable.arrayReview ?? [ArrayReviewStruct]()
                            for rows in moreReview{
                                self.arrayReviews.append(rows)
                            }
                            self.tblRating.reloadData()
                        }
                        else{
                            let responseValue = response.result.value
                            if responseValue != nil{
                                let arrayError = self.utilities.handleHttpResponseError(objectResponseError: responseValue as! Dictionary<String, Any> ,statusCode:statusCode)
                                self.showDialog(title:arrayError[0], message: arrayError[1])
                            }
                            else{
                                self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                            }
                        }
                    }
                    else{
                        self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                    }
                }
                catch{
                    self.dialogUtil.hideActivityIndicator(self.view)
                    self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                }
        }
    }
    
    
    
    func setChart(dataPoints:[String],values:[Double]){
        
        barChartRating.delegate = self
        
        var dataEntries:[BarChartDataEntry] = []
        var counter = 0.0
        
        for x in 0..<dataPoints.count{
            counter+=1.0
            let dataEntry = BarChartDataEntry(x: values[x], y: counter)
            dataEntries.append(dataEntry)
        }
        
        let barChartDataSet = BarChartDataSet(values: dataEntries, label: "Branch & Tech Rating(s)")
        let chartData = BarChartData()
        chartData.addDataSet(barChartDataSet)
       
        let left = barChartRating.getAxis(.left)
        left.drawLabelsEnabled = false
        
        // custom X-axis labels
        let xAxis                   = barChartRating.xAxis
        xAxis.valueFormatter        = axisFormatDelegate
        xAxis.labelPosition         = .bottom
        left.drawAxisLineEnabled    = false
        xAxis.granularity           = 1.0
       
        let description     =  Description();
        description.text    = "Branch & Technician Ratings"
        barChartRating.chartDescription = description
        
        barChartRating.legend.enabled  = false
        barChartRating.legend.drawInside = false
        
        barChartRating.xAxis.drawGridLinesEnabled           = false
        barChartRating.getAxis(.left).drawGridLinesEnabled  = false
        barChartRating.getAxis(.right).drawGridLinesEnabled = false
        barChartRating.setScaleEnabled(false)
        barChartRating.isMultipleTouchEnabled = false
        barChartRating.dragEnabled = false
        
        barChartRating.data             = chartData
        barChartRating.maxVisibleCount  = 5
        barChartRating.setVisibleXRangeMaximum(5)
        
        barChartRating.moveViewToX(1)
        barChartRating.pinchZoomEnabled         = false
        barChartRating.setScaleEnabled(false)
        barChartRating.isMultipleTouchEnabled   = false
        barChartRating.getAxis(.right).drawLabelsEnabled = false
        
        barChartDataSet.colors  = [#colorLiteral(red: 0.4666666667, green: 0.2549019608, blue: 0.003921568627, alpha: 1)]
        barChartRating.backgroundColor = UIColor.white
        barChartRating.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        barChartRating.invalidateIntrinsicContentSize()
        barChartRating.notifyDataSetChanged()
    }
    
    func getAverageRating() -> [Double]{
        
        print("Count Reviews: \(arrayReviews.count)")
        
        if arrayReviews.count > 0{
            var ave1stRate = 0.0;
            var ave2ndRate = 0.0;
            var ave3rdRate = 0.0;
            var ave4thRate = 0.0;
            var ave5thRate = 0.0;
            for rows in arrayReviews{
                
                let rating:Double = Double(rows.rating ?? Int(0))
                if(rating > 0 && rating == 1){
                    ave1stRate+=rating;
                }
                if(rating > 1 && rating == 2){
                    ave2ndRate+=rating;
                }
                if(rating > 2 && rating == 3){
                    ave3rdRate+=rating;
                }
                if(rating > 3 && rating == 4){
                    ave4thRate+=rating;
                }
                if(rating > 4 && rating == 5){
                    ave5thRate+=rating;
                }
            }
            var valueRating = [ave1stRate,ave2ndRate,ave3rdRate,ave4thRate,ave5thRate]
            return valueRating
        }
        return [Double]()
        
    }
    
    
    func showDialog(title:String,message:String){
        //alert box
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "Confirm", style: .default) { (action) in
            
        }
        alertView.addAction(confirm)
        present(alertView,animated: true,completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return arrayReviews.count
    }

  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell        = tableView.dequeueReusableCell(withIdentifier: "cellReviews", for: indexPath) as! BranchArrayReviewCell
        var clientImage     = arrayReviews[indexPath.row].user_picture ??  "no%20photo%20female.jpg"
        clientImage         = clientImage.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
        let imgURLString    = "\(SERVER_URL)/images/users/\(clientImage)"
        let imgURL          = URL(string: imgURLString)
        let client_name     = arrayReviews[indexPath.row].username
        let client_message  = arrayReviews[indexPath.row].feedback
        
        cell.lblClientName.text     = client_name
        cell.lblClientMessage.text  = client_message
        cell.imgClient.kf.setImage(with: imgURL)
        return cell
    }
   

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension BranchRatingController: IAxisValueFormatter {

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
         return arrayRatingScale[Int(value)]
    }
    
}
