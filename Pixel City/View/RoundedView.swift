import UIKit

@IBDesignable
class RoundedView: UIView {

    @IBInspectable var cornerRedius: CGFloat = 5.0 {
        didSet{
            self.layer.cornerRadius = self.cornerRedius
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
    
    private func SetupView(){
        self.layer.cornerRadius = self.cornerRedius
    }
    
}
