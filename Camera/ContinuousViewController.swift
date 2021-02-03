//
//  ContinuousViewController.swift
//  Camera
//
//  Created by 阿迦井翔 on 2021/01/23.
//

import UIKit
import AVFoundation

class ContinuousViewController: UIViewController {
    
    var imageArray = [UIImage]()
    var count = 0
    var capturecount = 0
    var timer: Timer?
    // デバイスからの入力と出力を管理するオブジェクトの作成
    var captureSession = AVCaptureSession()
    // カメラデバイスそのものを管理するオブジェクトの作成
    // メインカメラの管理オブジェクトの作成
    var mainCamera: AVCaptureDevice?
    // インカメの管理オブジェクトの作成
    var innerCamera: AVCaptureDevice?
    // 現在使用しているカメラデバイスの管理オブジェクトの作成
    var currentDevice: AVCaptureDevice?
    // キャプチャーの出力データを受け付けるオブジェクト
    var photoOutput : AVCapturePhotoOutput?
    // プレビュー表示用のレイヤ
    var cameraPreviewLayer : AVCaptureVideoPreviewLayer?
    // シャッターボタン
    @IBOutlet weak var cameraButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        captureSession.startRunning()
        styleCaptureButton()
        
        // 画面タップでピントをあわせる
        //                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.tappedScreen(_:)))
        //                let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(ViewController.pinchedGesture(_:)))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // シャッターボタンが押された時のアクション
    @IBAction func cameraButton_TouchUpInside(_ sender: Any) {
        count = count + 1
        
        if count == 1 {
            self.timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(ViewController.shatter), userInfo: nil, repeats: true)
            print(count)
        } else {
            self.timer?.invalidate()
            count = 0
            print(count)
        }
        
    }
    
    @objc func shatter() {
        let settings = AVCapturePhotoSettings()
        // フラッシュの設定
        settings.flashMode = .auto
        // カメラの手ぶれ補正
        settings.isAutoStillImageStabilizationEnabled = true
        // 撮影された画像をdelegateメソッドで処理
        self.photoOutput?.capturePhoto(with: settings, delegate: self as! AVCapturePhotoCaptureDelegate)
        
    }
    
    @IBAction func captureSegmented(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        
        case 0:
            capturecount = 1
            print(capturecount)
            print(captureSession.sessionPreset)
            
        case 1:
            capturecount = 2
            print(capturecount)
            print(captureSession.sessionPreset)
            
        case 2:
            capturecount = 3
            print(capturecount)
            print(captureSession.sessionPreset)
            
        default:
            capturecount = 0
            print(capturecount)
        }
    }
    
}

//MARK: AVCapturePhotoCaptureDelegateデリゲートメソッド
extension ContinuousViewController: AVCapturePhotoCaptureDelegate{
    // 撮影した画像データが生成されたときに呼び出されるデリゲートメソッド
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            print(imageArray)
            // Data型をUIImageオブジェクトに変換
            let uiImage = UIImage(data: imageData)!
            imageArray.append(uiImage)
        }
        savePhoto()
    }
    func savePhoto() {
        for image in imageArray {
            // 写真ライブラリに画像を保存
            UIImageWriteToSavedPhotosAlbum(image, nil,nil,nil)
        }
    }
}

//MARK: カメラ設定メソッド
extension ContinuousViewController{
    
    // カメラの画質の設定
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        captureSession.beginConfiguration()
        if captureSession.canSetSessionPreset(.low) && capturecount == 1 {
            captureSession.sessionPreset = .low
        } else if captureSession.canSetSessionPreset(.high) && capturecount == 2 {
            captureSession.sessionPreset = .high
        } else if capturecount == 3 {
            captureSession.sessionPreset = AVCaptureSession.Preset.photo
        }
        captureSession.commitConfiguration()
    }
    
    // デバイスの設定
    func setupDevice() {
        // カメラデバイスのプロパティ設定
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        // プロパティの条件を満たしたカメラデバイスの取得
        let devices = deviceDiscoverySession.devices
        
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                mainCamera = device
            } else if device.position == AVCaptureDevice.Position.front {
                innerCamera = device
            }
        }
        // 起動時のカメラを設定
        currentDevice = mainCamera
        
        // ズーム用のスライダー
        let slider: UISlider = UISlider()
        let sliderWidth: CGFloat = self.view.bounds.width * 0.5
        let sliderHeight: CGFloat = 40
        let sliderRect: CGRect = CGRect(x: (self.view.bounds.width - sliderWidth) / 2, y: self.view.bounds.height - 200, width: sliderWidth, height: sliderHeight)
        slider.frame = sliderRect
        slider.minimumValue = 0.0
        slider.maximumValue = 1.0
        slider.value = 0.0
        slider.addTarget(self, action: #selector(self.onSliderChanged(sender:)), for: .valueChanged)
        self.view.addSubview(slider)
    }
    
    @objc func onSliderChanged(sender: UISlider) {
        do {
            try self.mainCamera?.lockForConfiguration()
            self.mainCamera?.ramp(
                toVideoZoomFactor: (self.mainCamera?.minAvailableVideoZoomFactor)! + CGFloat(sender.value) * ((self.mainCamera?.maxAvailableVideoZoomFactor)! - (self.mainCamera?.minAvailableVideoZoomFactor)!),
                withRate: 5.0)
            self.mainCamera?.unlockForConfiguration()
        } catch {
            print("Failed to change zoom.")
        }
    }

    
    @IBAction func change() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // 入出力データの設定
    func setupInputOutput() {
        do {
            // 指定したデバイスを使用するために入力を初期化
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)
            // 指定した入力をセッションに追加
            captureSession.addInput(captureDeviceInput)
            // 出力データを受け取るオブジェクトの作成
            photoOutput = AVCapturePhotoOutput()
            // 出力ファイルのフォーマットを指定
            photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
        } catch {
            print(error)
        }
    }
    
    // カメラのプレビューを表示するレイヤの設定
    func setupPreviewLayer() {
        // 指定したAVCaptureSessionでプレビューレイヤを初期化
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        // プレビューレイヤが、カメラのキャプチャーを縦横比を維持した状態で、表示するように設定
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        // プレビューレイヤの表示の向きを設定
        self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        
        self.cameraPreviewLayer?.frame = view.frame
        self.view.layer.insertSublayer(self.cameraPreviewLayer!, at: 0)
    }
    
    // ボタンのスタイルを設定
    func styleCaptureButton() {
        cameraButton.layer.borderColor = UIColor.white.cgColor
        cameraButton.layer.borderWidth = 5
        cameraButton.clipsToBounds = true
        cameraButton.layer.cornerRadius = min(cameraButton.frame.width, cameraButton.frame.height) / 2
    }
    
}
