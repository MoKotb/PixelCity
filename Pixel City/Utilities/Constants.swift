import Foundation

let PHOTO_CELL_IDENTIFIER = "PhotoCell"
let DETAILS_IDENTIFIER = "DetailsVC"
let API_KEY = "f28d213ff37ea456c2b338f38cfde2ba"
let BASE_URL = "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(API_KEY)&"

typealias completionHandler = (_ completion:Bool) -> ()
