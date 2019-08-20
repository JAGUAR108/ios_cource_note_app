//
//  ColorPickerViewController.swift
//  Note
//
//  Created by Максим Бачурин on 18/07/2019.
//  Copyright © 2019 Максим Бачурин. All rights reserved.
//

import UIKit

class ColorPickerViewController: UIViewController {
    var currentColor: UIColor = .white

    @IBOutlet weak var colorPickerView: ColorPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colorPickerView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(orintationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        colorPickerView.installColor(color: currentColor)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func orintationDidChange() {
        colorPickerView.installColor(color: currentColor)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ColorPickerViewController: ColorPickerDelegate {
    func newColor(sender: ColorPickerView, color: UIColor) {
        saveColor(color: color)
        navigationController?.popViewController(animated: true)
    }
    
    func changedColor(sender: ColorPickerView, color: UIColor) {
        currentColor = color
    }
    
    private func saveColor(color: UIColor) {
        for editViewController in navigationController?.viewControllers ?? [] {
            if let editViewController = editViewController as? EditViewController {
                editViewController.newColor(color: color)
                return
            }
        }
    }
    
}
