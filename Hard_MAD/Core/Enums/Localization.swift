//
//  L10n.swift
//  Hard_MAD
//
//  Created by dark type on 28.02.2025.
//

import UIKit

enum L10n {
    enum Common {
        static let save = "common.save".localized
    }
    
    enum Auth {
        static let title = "auth.title".localized
        static let placeholder = "auth.placeholder".localized
    }
    
    enum Journal {
        static let title = "journal.title".localized
        
        enum Cell {
            static let title = "journal.cell.title".localized
        }
        
        enum Button {
            static let title = "journal.button.title".localized
        }
    }

    enum Emotions {
        static let title = "emotions.title".localized
    }
    
    enum Record {
        static let title = "record.title".localized
        
        enum Questions {
            static let question1 = "record.question1".localized
            static let question2 = "record.question2".localized
            static let question3 = "record.question3".localized
        }
    }
    
    enum Analysis {
        enum Title {
            static let categories = "analysis.title.categories".localized
            static let week = "analysis.title.week".localized
            static let frequent = "analysis.title.frequent".localized
            static let daily = "analysis.title.daily".localized
        }
    }
    
    enum Settings {
        static let title = "settings.title".localized
        
        enum Notifications {
            static let send = "settings.notifications".localized
            static let add = "settings.notificatoins.add".localized
        }
        
        enum Login {
            static let touchID = "settings.login.touch".localized
        }
    }
    
    enum TabBar {
        static let journal = "tabbar.journal".localized
        static let analysis = "tabbar.analysis".localized
        static let settings = "tabbar.settings".localized
    }
    
    enum Error {
        static let generic = "error.generic".localized
        static let network = "error.network".localized
    }
}

private extension String {
    var localized: String {
        let result = NSLocalizedString(self, bundle: .main, comment: "")
        print("Localizing key: \(self) to: \(result) with current locale: \(Locale.current.identifier)")
        return result
    }
    
    func localized(with arguments: CVarArg...) -> String {
        return String(format: localized, arguments: arguments)
    }
}
