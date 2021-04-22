import MobileCoreServices
import UIKit

/// Static factory for view controllers.
struct ViewControllerFactory {
    
    static func makeAuthorization(
        withSuccessHandler success: @escaping () -> ()
    ) -> AuthorizationController {
        
        let storyboard = UIStoryboard(name: "Authorization", bundle: nil)
        
        guard let controller = storyboard.instantiateInitialViewController() as? AuthorizationController else {
            fatalError("Could not instantiate controller.")
        }

        controller.didAuthorizeHandler = success
        controller.modalPresentationStyle = .formSheet
        controller.isModalInPresentation = true

        return controller
    }
    
    static func makeEditor(
        with source: VideoSource,
        previewImage: UIImage?,
        delegate: EditorViewControllerDelegate?
    ) -> EditorViewController {
        
        let storyboard = UIStoryboard(name: "Editor", bundle: nil)
        let videoController = VideoController(source: .url(URL.init(string: "http://www.exit109.com/~dnn/clips/RW20seconds_2.mp4")!), previewImage: nil)
        
        guard let controller = storyboard.instantiateInitialViewController(creator: {
            EditorViewController(videoController: videoController, delegate: delegate, coder: $0)
        }) else { fatalError("Could not instantiate controller.") }
        
        return controller
    }
    
    static func makeFilePicker(
        withDelegate delegate: UIDocumentPickerDelegate?
    ) -> UIDocumentPickerViewController {
        
        let picker: UIDocumentPickerViewController
        
        if #available(iOS 14.0, *) {
            picker = UIDocumentPickerViewController(
                forOpeningContentTypes: [.movie],
                asCopy: true
            )
        } else {
            picker = UIDocumentPickerViewController(
                documentTypes: [kUTTypeMovie as String],
                in: .import
            )
        }
        
        picker.shouldShowFileExtensions = true
        picker.delegate = delegate
        return picker
    }
    
    /// A picker configured to record videos if the device can record videos, otherwise `nil`.
    ///
    /// If the preferred camera is not available, falls back to `.rear`.
    static func makeCamera(
        with preferredCamera: UIImagePickerController.CameraDevice,
        delegate: UIImagePickerController.Delegate? = nil
    ) -> UIImagePickerController? {
        
        guard UIImagePickerController.canRecordVideos else { return nil }
        
        let camera = UIImagePickerController.isCameraDeviceAvailable(preferredCamera)
            ? preferredCamera
            : .rear
        
        let picker = UIImagePickerController()
        
        picker.delegate = delegate
        picker.mediaTypes = [kUTTypeMovie as String]
        picker.sourceType = .camera
        picker.cameraCaptureMode = .video
        picker.cameraDevice = camera
        picker.videoQuality = .typeHigh
        
        picker.modalPresentationStyle = .fullScreen
        
        return picker
    }
}
