//
//  TimePickerViewControllerDelegate.swift
//  Hard_MAD
//
//  Created by dark type on 03.03.2025.
//

import UIKit

@MainActor
protocol TimePickerViewControllerDelegate: AnyObject {
    func timePickerViewController(_ controller: TimePickerViewController, didSelectTime time: String)
    func timePickerViewControllerDidCancel(_ controller: TimePickerViewController)
}
