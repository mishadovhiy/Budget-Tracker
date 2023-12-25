//
//  CameraTextMLVC.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 28.11.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit
import AVFoundation

class CameraTextMLVC:SuperViewController {
    
    @IBOutlet weak var toLibraryView: TouchView!
    @IBOutlet weak var makePhotoView: TouchView!
    @IBOutlet weak var cameraHolderView: UIView!
    
    var cameraModel:CameraModel!
    var selectionDelegate:ImagePreviewProtocol?
    override func viewDidDismiss() {
        super.viewDidDismiss()
        selectionDelegate = nil
        cameraModel = nil
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("CameraTextMLVCCameraTextMLVC")
        cameraModel = .init(view: cameraHolderView)
        makePhotoView.pressedAction = {
            self.cameraModel.capture(delegate: self)
        }
        toLibraryView.pressedAction = toLibraryPressed
    }
    
    var appeareCalled:Bool = false
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        if appeareCalled {
            cameraModel.resume()
        } else {
            appeareCalled = true
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        cameraModel.stop()
    }
    
    func toLibraryPressed() {
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        imgPicker.allowsEditing = true
        DispatchQueue.main.async {
            AppDelegate.properties?.appData.present(vc: imgPicker, presentingVC: self.selectionDelegate as! SelectTextImageContainerView)
        }
    }
    
    
    func toImgPreview(_ img:UIImage) {
        if #available(iOS 13.0, *) {
            if let nav = navigationController {
                nav.pushViewController(ImagePreviewVC.configure(img: img.pngData(), delegate: selectionDelegate), animated: true)

            }
        }
        
    }
}


extension CameraTextMLVC:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selected = (info[.editedImage] as? UIImage)
        else { return }
        picker.dismiss(animated: true)

        toImgPreview(selected)
    }
}

extension CameraTextMLVC:AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {

        guard let imgData = photo.fileDataRepresentation(),
              let image = UIImage(data:imgData),
              error == nil
        else {
            return
        }
        
        toImgPreview(image)

    }

}

extension CameraTextMLVC {
    static func configure(delegate:ImagePreviewProtocol?) -> CameraTextMLVC {
        let vc = UIStoryboard(name: "Reusable", bundle: nil).instantiateViewController(withIdentifier: "CameraTextMLVC") as! CameraTextMLVC
        vc.selectionDelegate = delegate
        return vc
    }
}
