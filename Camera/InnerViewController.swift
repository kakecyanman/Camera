//
//  InnerViewController.swift
//  Camera
//
//  Created by 阿迦井翔 on 2021/01/23.
//

import UIKit
import AVFoundation

class InnerViewController: UIViewController {
    
    var colorcount = 0
    var flashcount = 0

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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // シャッターボタンが押された時のアクション
    @IBAction func cameraButton_TouchUpInside(_ sender: Any) {
        
        if colorcount == 0 {
            shatter()
        } else if colorcount == 5 {
            performSegue(withIdentifier: "toRed", sender: nil)
            UIScreen.main.brightness = 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.shatter()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                UIScreen.main.brightness = 0.3
            }
        } else if colorcount == 10 {
            performSegue(withIdentifier: "toBlue", sender: nil)
            UIScreen.main.brightness = 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.shatter()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                UIScreen.main.brightness = 0.3
            }
        } else if colorcount == 15 {
            performSegue(withIdentifier: "toYellow", sender: nil)
            UIScreen.main.brightness = 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.shatter()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                UIScreen.main.brightness = 0.3
            }
        } else if colorcount == 20 {
            performSegue(withIdentifier: "toGreen", sender: nil)
            UIScreen.main.brightness = 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.shatter()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                UIScreen.main.brightness = 0.3
            }
        } else if colorcount == 25 {
            performSegue(withIdentifier: "toPink", sender: nil)
            UIScreen.main.brightness = 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.shatter()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                UIScreen.main.brightness = 0.3
            }
        } else if colorcount == 30 {
            performSegue(withIdentifier: "toPurple", sender: nil)
            UIScreen.main.brightness = 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.shatter()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                UIScreen.main.brightness = 0.3
            }
        }
    }
    
    @objc func shatter() {
        let settings = AVCapturePhotoSettings()
        // フラッシュの設定
        if flashcount == 1 {
            settings.flashMode = .on
        } else if flashcount == 0 {
            settings.flashMode = .off
        }
        // カメラの手ぶれ補正
        settings.isAutoStillImageStabilizationEnabled = true
        // 撮影された画像をdelegateメソッドで処理
            self.photoOutput?.capturePhoto(with: settings, delegate: self as! AVCapturePhotoCaptureDelegate)
    }

    @IBAction func colorSegmented(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        
        case 0:
            colorcount = 0
            print(colorcount)
        //red
        case 1:
            colorcount = 5
            print(colorcount)
        //blue
        case 2:
            colorcount = 10
            print(colorcount)
        //yellow
        case 3:
            colorcount = 15
            print(colorcount)
        //green
        case 4:
            colorcount = 20
            print(colorcount)
        //pink
        case 5:
            colorcount = 25
            print(colorcount)
        //purple
        case 6:
            colorcount = 30
            print(colorcount)
            
        default:
            colorcount = 0
            print(colorcount)
        }
    }
    
    @IBAction func flashBt(_ sender: UISwitch) {
        if sender.isOn == true {
            flashcount = 1
        } else {
            flashcount = 0
        }
    }
    
    
}

//MARK: AVCapturePhotoCaptureDelegateデリゲートメソッド
extension InnerViewController: AVCapturePhotoCaptureDelegate{
    // 撮影した画像データが生成されたときに呼び出されるデリゲートメソッド
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            // Data型をUIImageオブジェクトに変換
            let uiImage = UIImage(data: imageData)
            UIImageWriteToSavedPhotosAlbum(uiImage!, nil,nil,nil)
        }
    }
}

//MARK: カメラ設定メソッド
extension InnerViewController{
    // カメラの画質の設定
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
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
        currentDevice = innerCamera
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
