import Foundation
import Alamofire
import AlamofireImage
import SwiftyJSON

class PhotosServices{
    
    static let instance = PhotosServices()
    var imagesURLArray = [String]()
    var imagesArray = [UIImage]()
    
    func FlickrURL(withAnnotation annotation:DroppablePin,andNumberOfPhotos number:Int) ->String{
        return "\(BASE_URL)lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
    }
    
    func GetPhotosData(withURL url:String,completion: @escaping completionHandler){
        ClearImagesURL()
        ClearImages()
        Alamofire.request(url).responseJSON { (response) in
            guard let data = response.data else { return }
            do{
                let json = try JSON(data: data)
                let photos = json["photos"]["photo"]
                for (_, object) in photos {
                    let farm = object["farm"].intValue
                    let server = object["server"].intValue
                    let id = object["id"].intValue
                    let secret = object["secret"].stringValue
                    let imageURL = "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_z_d.jpg"
                    self.imagesURLArray.append(imageURL)
                }
                completion(true)
            }catch let error {
                debugPrint(error.localizedDescription)
                completion(false)
            }
        }
    }
    
    func DownloadImages(progessText:UILabel,completion: @escaping completionHandler){
        
        for url in imagesURLArray{
            Alamofire.request(url).responseImage { (response) in
                guard let image = response.result.value else { return }
                self.imagesArray.append(image)
                progessText.text = "\(self.imagesArray.count) / 40 Photos Downloaded"
                if self.imagesURLArray.count == self.imagesArray.count {
                    completion(true)
                }else{
                    completion(false)
                }
            }
        }
    }
    
    func CancelAllSession(){
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionData, uploadData, downloadData) in
            sessionData.forEach({ $0.cancel() })
            uploadData.forEach({ $0.cancel() })
            downloadData.forEach({ $0.cancel() })
        }
    }
    
    func GetImagesArray() -> [UIImage]{
        return imagesArray
    }
    
    func ClearImagesURL(){
        imagesURLArray.removeAll()
    }
    
    func ClearImages(){
        imagesArray.removeAll()
    }
}
