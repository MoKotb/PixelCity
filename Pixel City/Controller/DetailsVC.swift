import UIKit

class DetailsVC: UIViewController , UIGestureRecognizerDelegate {

    @IBOutlet weak var detailsImage: UIImageView!
    var selectedImage :UIImage?
    
    func initData(forImage image:UIImage){
        selectedImage = image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailsImage.image = selectedImage
        DoubleTap()
    }
    
    private func DoubleTap(){
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(CloseDetails))
        doubleTap.delegate = self
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
    }
    
    @objc private func CloseDetails(){
        dismiss(animated: true, completion: nil)
    }
    
}
