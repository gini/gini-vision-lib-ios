//
//  OnboardingDigitalInvoiceViewController.swift
//  GiniVision
//
//  Created by Nadya Karaban on 21.10.20.
//

import Foundation
@objcMembers public final class DigitalInvoiceOnboardingViewController: UIViewController {
    let giniConfiguration: GiniConfiguration = GiniConfiguration.shared

    @IBOutlet var topImageView: UIImageView!
    @IBOutlet var badgeImageView: UIImageView!
    @IBOutlet var firstLabel: UILabel!
    @IBOutlet var helpItemImageView: UIImageView!
    @IBOutlet var secondLabel: UILabel!
    @IBOutlet var doneButton: UIButton!

    fileprivate var topImage: UIImage {
        return UIImageNamedPreferred(named: "digital_invoice_onboarding_icon") ?? UIImage()
    }

    fileprivate var badgeImage: UIImage {
        return UIImageNamedPreferred(named: "digital_invoice_onboarding_new_badge") ?? UIImage()
    }

    fileprivate var helpItemImage: UIImage {
        return UIImageNamedPreferred(named: "digital_invoice_onboarding_item_help") ?? UIImage()
    }

    fileprivate var firstLabelText: String {
        return NSLocalizedStringPreferredFormat("ginivision.digitalinvoice.onboarding.text1", fallbackKey: "", comment: "title for the first label on the digital invoice onboarding screen", isCustomizable: true)
    }

    fileprivate var secondLabelText: String {
        return NSLocalizedStringPreferredFormat("ginivision.digitalinvoice.onboarding.text2", fallbackKey: "", comment: "title for the second label on the digital invoice onboarding screen", isCustomizable: true)
    }

    fileprivate var doneButtonTitle: String {
        return NSLocalizedStringPreferredFormat("ginivision.digitalinvoice.onboarding.donebutton", fallbackKey: "", comment: "title for the done button on the digital invoice onboarding screen", isCustomizable: true)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    fileprivate func configureUI() {
        title = .localized(resource: DigitalInvoiceStrings.screenTitle)
        view.backgroundColor = UIColor.from(giniColor: giniConfiguration.digitalInvoiceOnboardingBackgroundColor)

        topImageView.image = topImage

        badgeImageView.image = badgeImage

        firstLabel.text = firstLabelText
        firstLabel.font = giniConfiguration.digitalInvoiceOnboardingTextFont
        firstLabel.textColor = UIColor.from(giniColor: giniConfiguration.digitalInvoiceOnboardingTextColor)

        helpItemImageView.image = helpItemImage

        secondLabel.text = secondLabelText
        secondLabel.font = giniConfiguration.digitalInvoiceOnboardingTextFont
        secondLabel.textColor = UIColor.from(giniColor: giniConfiguration.digitalInvoiceOnboardingTextColor)

        doneButton.layer.cornerRadius = 4.0
        doneButton.backgroundColor = UIColor.from(giniColor: giniConfiguration.digitalInvoiceOnboardingDoneButtonBackgroundColor)
        doneButton.tintColor = UIColor.from(giniColor: giniConfiguration.digitalInvoiceOnboardingDoneButtonTextColor)
        doneButton.setTitle(doneButtonTitle, for: .normal)
        doneButton.titleLabel?.font = giniConfiguration.digitalInvoiceOnboardingDoneButtonTextFont
        doneButton.addTarget(self, action: #selector(doneAction(_:)), for: .touchUpInside)
    }

    @objc func doneAction(_ sender: UIButton!) {
        dismiss(animated: true) {
            UserDefaults.standard.set(true, forKey: "ginivision.defaults.digitalInvoiceOnboardingShowed")
        }
    }
}
