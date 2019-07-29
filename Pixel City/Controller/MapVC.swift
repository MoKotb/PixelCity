import UIKit
import MapKit
import CoreLocation

class MapVC: UIViewController , UIGestureRecognizerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photosView: UIView!
    @IBOutlet weak var photosViewHeight: NSLayoutConstraint!
    
    let locationManager:CLLocationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius:Double = 1000
    
    var spinner:UIActivityIndicatorView?
    var progressText:UILabel?
    var photosCollection:UICollectionView?
    var flowLayout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    
    let screenSize = UIScreen.main.bounds
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        
        
        ConfigureLocationServices()
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(DropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
        
        SetupCollectionView()
        
        registerForPreviewing(with: self, sourceView: photosCollection)
    }
    
    private func SwipeView(){
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipe.direction = .down
        photosView.addGestureRecognizer(swipe)
    }
    
    private func animateViewUp(){
        PhotosServices.instance.CancelAllSession()
        photosViewHeight.constant = 340
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func animateViewDown(){
        photosViewHeight.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func SetupCollectionView(){
        photosCollection = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        photosCollection?.register(PhotoCell.self, forCellWithReuseIdentifier: PHOTO_CELL_IDENTIFIER)
        photosCollection?.dataSource = self
        photosCollection?.delegate = self
        photosCollection?.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        photosView.addSubview(photosCollection!)
    }
    
    private func AddSpinner(){
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (screenSize.width / 2) - ((spinner?.frame.width)! / 2), y: (photosView.bounds.height / 2) - ((spinner?.frame.height)! / 2))
        spinner?.style = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        spinner?.startAnimating()
        photosCollection?.addSubview(spinner!)
    }
    
    private func RemoveSpinner(){
        if spinner != nil{
            spinner?.removeFromSuperview()
        }
    }
    
    private func AddProgressText(){
        progressText = UILabel()
        progressText?.frame = CGRect(x: (screenSize.width / 2) - 120 , y: (photosView.frame.height / 2) + 16, width: 240, height: 40)
        progressText?.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        progressText?.font = UIFont(name: "Avenir Next", size: 17)
        progressText?.textAlignment = .center
        photosCollection?.addSubview(progressText!)
    }
    
    private func RemoveProgressText(){
        if progressText != nil{
            progressText?.removeFromSuperview()
        }
    }
    

    
    @IBAction func OnLocationPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse{
            CenterMapOnUserLocation()
        }
    }
}

extension MapVC : MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation{
            return nil
        }
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotation.pinTintColor = #colorLiteral(red: 0.9771530032, green: 0.7062081099, blue: 0.1748393774, alpha: 1)
        pinAnnotation.animatesDrop = true
        return pinAnnotation
    }
    
    func CenterMapOnUserLocation(){
        guard let coordinate = locationManager.location?.coordinate else { return }
        ZoomOn(coordinate: coordinate)
    }
    
    private func ZoomOn(coordinate:CLLocationCoordinate2D){
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @objc private func DropPin(sender:UITapGestureRecognizer){
        RemovePin()
        RemoveSpinner()
        RemoveProgressText()
        PhotosServices.instance.CancelAllSession()
        
       
        
        let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
        mapView.addAnnotation(annotation)
        ZoomOn(coordinate: touchCoordinate)
        
        animateViewUp()
        SwipeView()
        AddSpinner()
        AddProgressText()
        
        let url = PhotosServices.instance.FlickrURL(withAnnotation: annotation, andNumberOfPhotos: 40)
        PhotosServices.instance.GetPhotosData(withURL: url) { (Success) in
            if Success {
                PhotosServices.instance.DownloadImages(progessText: self.progressText!, completion: { (Finished) in
                    if Finished{
                        self.RemoveSpinner()
                        self.RemoveProgressText()
                        self.photosCollection?.reloadData()
                    }
                })
            }
        }
        self.photosCollection?.reloadData()
    }
    
    private func RemovePin(){
        for annotatin in mapView.annotations{
            mapView.removeAnnotation(annotatin)
        }
    }
}

extension MapVC : CLLocationManagerDelegate{
    
    func ConfigureLocationServices(){
        if authorizationStatus == .notDetermined{
            locationManager.requestAlwaysAuthorization()
        }else{
            return
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        CenterMapOnUserLocation()
    }
}

extension MapVC : UICollectionViewDelegate , UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PhotosServices.instance.GetImagesArray().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PHOTO_CELL_IDENTIFIER, for: indexPath) as? PhotoCell {
            let imageForIndex = PhotosServices.instance.GetImagesArray()[indexPath.row]
            let image = UIImageView(image: imageForIndex)
            cell.addSubview(image)
            return cell
        }else{
            return PhotoCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let detailsVC = storyboard?.instantiateViewController(withIdentifier: DETAILS_IDENTIFIER) as? DetailsVC else { return }
        let imageForIndex = PhotosServices.instance.GetImagesArray()[indexPath.row]
        detailsVC.initData(forImage: imageForIndex)
        present(detailsVC, animated: true, completion: nil)
    }
}

extension MapVC : UIViewControllerPreviewingDelegate{
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = photosCollection?.indexPathForItem(at: location) , let cell = photosCollection?.cellForItem(at: indexPath) else { return nil }
        guard let detailsVC = storyboard?.instantiateViewController(withIdentifier: DETAILS_IDENTIFIER) as? DetailsVC else { return nil}
        let imageForIndex = PhotosServices.instance.GetImagesArray()[indexPath.row]
        detailsVC.initData(forImage: imageForIndex)
        previewingContext.sourceRect = cell.contentView.frame
        return detailsVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}
