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
           
        enum Statistics {
            enum Records {
                static func plural(_ count: Int) -> String {
                    let key = "statistics.records"
                    return String.localizedPlural(for: count, key: key)
                }
            }
               
            enum Today {
                static let title = "statistics.today.title".localized
                static func plural(_ count: Int) -> String {
                    let key = "statistics.today"
                    return String.localizedPlural(for: count, key: key)
                }
            }
               
            enum Streak {
                static let title = "statistics.streak.title".localized
                static func plural(_ count: Int) -> String {
                    let key = "statistics.streak"
                    return String.localizedPlural(for: count, key: key)
                }
            }
               
            static func format(type: StatType, count: Int) -> String {
                let title: String
                let plural: String
                   
                switch type {
                case .records:
                    title = ""
                    plural = Records.plural(count)
                    return "\(count) \(plural)"
                case .today:
                    title = Today.title
                    plural = Today.plural(count)
                case .streak:
                    title = Streak.title
                    plural = Streak.plural(count)
                }
                   
                return "\(title): \(count) \(plural)"
            }
        }
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

    static func localizedPlural(for number: Int, key: String) -> String {
        let form = RussianPluralForm.forNumber(number)
        
        let suffixKey: String
        switch form {
        case .one:
            suffixKey = "\(key).one"
        case .few:
            suffixKey = "\(key).few"
        case .many:
            suffixKey = "\(key).many"
        }
        
        return NSLocalizedString(suffixKey, comment: "")
    }
}

enum RussianPluralForm {
    case one
    case few
    case many
    
    static func forNumber(_ number: Int) -> RussianPluralForm {
        let lastDigit = number % 10
        let lastTwoDigits = number % 100
        
        if lastTwoDigits >= 11 && lastTwoDigits <= 19 {
            return .many
        }
        
        switch lastDigit {
        case 1:
            return .one
        case 2, 3, 4:
            return .few
        default:
            return .many
        }
    }
}
