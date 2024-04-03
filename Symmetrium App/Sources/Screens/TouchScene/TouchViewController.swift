//
//  TouchViewController.swift
//  SymmetriumDemoProj
//
//  Created by Sergiy Brotsky on 03.04.2024.
//  Copyright © 2024 Stas Seldin. All rights reserved.
//

import Foundation
import UIKit
import Combine

class TouchViewController: UIViewController {
    private var touchView: UIView!
    private let webRTCClient: WebRTCClient

    private var cancelable = Set<AnyCancellable>()
    
    
    init(webRTCClient: WebRTCClient) {
        self.webRTCClient = webRTCClient
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        subscribe()
    }

    private func setupUI() {
        touchView = UIView(frame: view.bounds)
        touchView.backgroundColor = .white
        view.addSubview(touchView)
        
        let touchRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        touchView.addGestureRecognizer(touchRecognizer)
    }

    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let touchPoint = gestureRecognizer.location(in: touchView)
        let x = touchPoint.x
        let y = touchPoint.y
        
        // Send touch coordinates via WebRTC data channel
        let model = TouchModel(x: x, y: y)
        webRTCClient.sendData(type: .touch, model)
    }

    func drawCircle(at point: CGPoint) {
        let circleView = UIView(frame: CGRect(x: point.x - 5, y: point.y - 5, width: 10, height: 10))
        circleView.backgroundColor = .red
        circleView.layer.cornerRadius = 5
        touchView.addSubview(circleView)
    }
    
    // MARK: Combine
    
    func subscribe() {
        
        let queue = DispatchQueue(label: "touch-scene-queue", attributes: .concurrent)
        
        webRTCClient.touchEventSubject
            .throttle(for: .milliseconds(500), scheduler: queue, latest: true)
            .sink { [weak self] touchModel in
                DispatchQueue.main.async {
                    self?.drawCircle(at: .init(x: touchModel.x, y: touchModel.y))
                }
                
            }
            .store(in: &cancelable)
        
    }
}
