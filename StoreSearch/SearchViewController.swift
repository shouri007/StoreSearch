//
//  ViewController.swift
//  StoreSearch
//
//  Created by Shouri on 08/01/16.
//  Copyright © 2016 Shouri. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    
    @IBOutlet weak var searchBar:UISearchBar!
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var segmentedControl:UISegmentedControl!
    
    var dataTask:NSURLSessionDataTask?
    var searchResults=[SearchResult]()
    var hasSearched=false
    var isLoading=false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let cellNib=UINib(nibName: "SearchResultCell", bundle: nil)
        let ntgCellNib=UINib(nibName: "NothingFoundCell", bundle: nil)
        let loadingCell=UINib(nibName: "LoadingCell", bundle: nil)

        tableView.registerNib(cellNib, forCellReuseIdentifier: "SearchResultCell")
        tableView.registerNib(ntgCellNib, forCellReuseIdentifier:"NothingFoundCell")
        tableView.rowHeight=80
        tableView.contentInset=UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0)
        tableView.registerNib(loadingCell, forCellReuseIdentifier: "LoadingCell")
        searchBar.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func parseJSON(data:NSData)->[String: AnyObject]?{

        do{
            let json=try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject]
                return json
        }catch{
                print("JSON Error: \(error)")
        }
        
        return nil
    }
    
    func parseDictionary(dictionary:[String : AnyObject])->[SearchResult]{
        
        var searchResults=[SearchResult]()
        if let array:AnyObject=dictionary["results"]{
            for resultDict in array as! [AnyObject]{
                if let resultDict = resultDict as? [String:AnyObject]{
                    var searchResult=SearchResult?()
                    if let wrapperType=resultDict["wrapperType"] as? NSString{
                        switch(wrapperType){
                            case "track":
                                searchResult=parseTrack(resultDict)
                            case "audiobook":
                                searchResult=parseAudioBook(resultDict)
                            case "software":
                                searchResult=parseSoftware(resultDict)
                            default:
                                break
                        }
                    }else if let kind=resultDict["kind"] as? NSString{
                        if kind=="ebook"{
                            searchResult=parseEBook(resultDict)
                        }
                    }
                    if let result = searchResult{
                        searchResults.append(result)
                    }
                }else{
                    print("Dictionary Expected")
                }
            }
        }else{
            print("Expected a results array")
        }
        return searchResults
    }
    
    
    func parseTrack(dictionary:[String:AnyObject])->SearchResult{
        
        let searchResult=SearchResult()
        
        searchResult.name=dictionary["trackName"] as! String
        searchResult.artistName=dictionary["artistName"] as! String
        searchResult.artworkURL60=dictionary["artworkUrl60"] as! String
        searchResult.artworkURL100=dictionary["artworkUrl100"] as! String
        searchResult.storeURL=dictionary["trackViewUrl"] as! String
        searchResult.kind=dictionary["kind"] as! String
        searchResult.currency=dictionary["currency"] as! String
        
        if let price=dictionary["trackPrice"] as? NSNumber{
            searchResult.price=Double(price)
        }
        
        if let genre=dictionary["primaryGenreName"] as? String{
            searchResult.genre=genre
        }
        return searchResult
    }
    
    func parseAudioBook(dictionary:[String:AnyObject])->SearchResult{
        
        let searchResult = SearchResult()
        searchResult.name = dictionary["collectionName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["collectionViewUrl"] as! String
        searchResult.kind = "audiobook"
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["collectionPrice"] as? NSNumber {
            searchResult.price = Double(price)
        }
        if let genre = dictionary["primaryGenreName"] as? NSString {
            searchResult.genre = genre as String
        }
        
        return searchResult
    }
    
    func parseSoftware(dictionary:[String:AnyObject])->SearchResult{
            
        let searchResult = SearchResult()
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["price"] as? NSNumber {
            searchResult.price = Double(price)
        }
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        return searchResult
    }
    
    func parseEBook(dictionary: [String: AnyObject]) -> SearchResult {
                
        let searchResult = SearchResult()
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["price"] as? NSNumber {
            searchResult.price = Double(price)
        }
                
        return searchResult
    }
    
    @IBAction func segmentChanged(sender:UISegmentedControl){
        performSearch()
    }
    
    func showNetworkError(){
        
        let alert=UIAlertController(title: "Whoops...", message: "There was an error reading from iTunes Store." + "\n Please try again.", preferredStyle: .Alert)
        let action=UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
}

extension SearchViewController:UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(searchBar:UISearchBar){
        performSearch()
    }
    
    func performSearch(){
        
        if(((searchBar.text?.isEmpty) != nil)){
            
            searchBar.resignFirstResponder()
            dataTask?.cancel()
            isLoading=true
            tableView.reloadData()
            hasSearched=true
            searchResults=[SearchResult]()
            
            let url=self.urlWithSearchText(searchBar.text!,category: segmentedControl.selectedSegmentIndex)
            let session=NSURLSession.sharedSession()
            dataTask=session.dataTaskWithURL(url, completionHandler: {
                    data,response,error in
                if let error=error{
                    print("Error: \(error)")
                    if(error.code == -999){
                        return
                    }
                }else if let httpResponse=response as? NSHTTPURLResponse{
                    if(httpResponse.statusCode==200){
                        if let dictionary=self.parseJSON(data!){
                            self.searchResults=self.parseDictionary(dictionary)
                            //return searchResults.sort(result1,result2)
                            dispatch_async(dispatch_get_main_queue()){
                                self.isLoading=false
                                self.tableView.reloadData()
                            }
                            return
                        }
                    }else{
                        print("Failure:\(response)")
                    }
                }
                dispatch_async(dispatch_get_main_queue()){
                    self.hasSearched=false
                    self.isLoading=false
                    self.tableView.reloadData()
                    self.showNetworkError()
                }
            })
            
            dataTask?.resume()
        }
    }
    
    func urlWithSearchText(searchText:String,category:Int)->NSURL{
        
        var entityName:String
        switch category{
            case 1: entityName="musicTrack"
            case 2: entityName="software"
            case 3: entityName="ebook"
            default:entityName=""
        }
        let escapedSearchText=searchText.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let urlString=String(format: "http://itunes.apple.com/search?term=%@&entity=%@",escapedSearchText,entityName)
        let url=NSURL(string: urlString)
        return url!
        
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}

extension SearchViewController:UITableViewDataSource{
 
    func tableView(tableView:UITableView,numberOfRowsInSection section:Int)->Int{
        
        if(isLoading){
            return 1
        }
        if(!hasSearched){
            return 0
        }
        else if(searchResults.count==0){
            return 1
        }else{
            return searchResults.count
        }
    }
    
    func tableView(tableView:UITableView,didSelectRowAtIndexPath indexPath:NSIndexPath){
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("ShowDetail", sender: indexPath)
    }
    
    func tableView(tableView:UITableView,willSelectRowAtIndexPath indexPath:NSIndexPath)->NSIndexPath?{
        if(searchResults.count==0 || isLoading){
            return nil
        }else{
            return indexPath
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        if(isLoading){
            
            let cell=tableView.dequeueReusableCellWithIdentifier("LoadingCell", forIndexPath: indexPath) as! UITableViewCell
            let spinner=cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        }
        if(searchResults.count==0){
            return tableView.dequeueReusableCellWithIdentifier("NothingFoundCell", forIndexPath: indexPath) as UITableViewCell!
        }
        else{
            
            let cell=tableView.dequeueReusableCellWithIdentifier("SearchResultCell", forIndexPath: indexPath) as! SearchResultCell
            let searchResult=searchResults[indexPath.row]
            cell.configureForSearchResult(searchResult)
            return cell
        }
        
    }
}

extension SearchViewController:UITableViewDelegate{
}
