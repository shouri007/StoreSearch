//
//  SearchResultCell.swift
//  StoreSearch
//
//  Created by Shouri on 10/01/16.
//  Copyright © 2016 Shouri. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {

    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var artistNameLabel:UILabel!
    @IBOutlet weak var artWorkImageView:UIImageView!
    var downloadTask:NSURLSessionDownloadTask?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let selectedView=UIView(frame: CGRect.zero)
        selectedView.backgroundColor=UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 0.5)
        selectedBackgroundView=selectedView
    }

    override func setSelected(selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
    }
    
    func configureForSearchResult(searchResult:SearchResult){
        
        nameLabel.text=searchResult.artistName
        if searchResult.artistName.isEmpty{
                artistNameLabel.text="Unknown"
        }else{
            artistNameLabel.text=String(format:"%@ (%@)",searchResult.artistName,kindForDisplay(searchResult.kind))
        }

        artWorkImageView!.image=UIImage(named: "Placeholder")
        print(searchResult.artworkURL60)
        if let url=NSURL(string: searchResult.artworkURL60){
            downloadTask=artWorkImageView!.loadImageWithURL(url)
        }

    }
    
    func kindForDisplay(kind:String)->String{
        
        switch kind{
        case "album":return "Album"
        case "audiobook":return "Audio Book"
        case "book":return "Book"
        case"ebook":return "E-Book"
        case "feature-movie": return "Movie"
        case "music-video": return "Music Video"
        case "podcast": return "Podcast"
        case "software": return "App"
        case "song": return "Song"
        case "tv-episode": return "TV Episode"
        default: return kind
        }
    }

    override func prepareForReuse() {
        
        super.prepareForReuse()
        
        downloadTask?.cancel()
        nameLabel.text=nil
        artistNameLabel.text=nil
        artWorkImageView.image=nil
    }
}
