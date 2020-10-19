Return Assistant
=============================

The Return Assistant feature utilises our latest invoice analysis technology that allows to additionaly recognise each line item including the quantity and unit price.

When the Return Assistant feature is enabled, users will be shown a digital version of the invoice that shows each line item. They can deselect items they decide to return and not pay for as well as specify a return reason for each deselected item. The total amount to pay is dynamically calculated as the line items are edited. They will also be able to edit the name, quantity, and unit price for each line item.

Once the user is happy with their invoice, they tap the "Pay" button and the updated extractions are returned to the client code.

The feature comprises two screens: the digital invoice and the line item detail screen (`DigitalInvoiceViewController` and `LineItemDetailsViewController` respectively). The former displays the line items and the total amount to pay as well as allowing to deselect entire line items, while the latter allows the user to edit all details of a particular line item.

## Requirements

To use this feature your client id must be configured to include line item extractions.

## Integration

### Screen API

The simplest way to integrate the Return Assistent is to use the Screen API. All you need to do to enable the Return Assistant is set the `returnAssistantEnabled` property to `true`  on your `GiniConfiguration` instance that you pass to the GVL view controller builder function:

```swift

let giniConfiguration = GiniConfiguration()
giniConfiguration.returnAssistantEnabled = true

let viewController = GiniVision.viewController(withClient: client,
                                               importedDocuments: visionDocuments,
                                               configuration: giniConfiguration,
                                               resultsDelegate: self,
                                               documentMetadata: documentMetadata)
```
If the invoice that the user scanned contains line item that the Gini extraction managed to parse, the user will
be shown the Return Assistant UI and be able to make all of the adjustments. 

The `amountToPay` extraction that will be returned to your results delegate will have the amount adjusted by the user. The `AnalysisResult` will also contain the line items including any modifications the users have made.

### Component API

The Return Assistant uses the extractions returned from the Gini service in order to display a digitalised version of the invoice that they scanned. In order to facilitate that in the Component API, use the extraction result to initialise a `DigitalInvoice` instance. The initialisation will succeed if the result contains the line item information.

This `DigitalInvoice` instance can then be used to set up and show an instance of the `DigitalInvoiceViewController`. 

```swift
documentService?.startAnalysis { result in
    DispatchQueue.main.async { [weak self] in
        
        guard let self = self else { return }
        
        switch result {
        case .success(let extractionResult):
            
            do {
                let digitalInvoice = try DigitalInvoice(extractionResult: extractionResult)
                
                // The Digital Invoice was created successfully.
                // Show the DigitalInvoiceViewController
                let digitalInvoiceViewController = DigitalInvoiceViewController()
                digitalInvoiceViewController.giniConfiguration = giniConfiguration
                digitalInvoiceViewController.invoice = digitalInvoice
                digitalInvoiceViewController.delegate = self
                
                navigationController.pushViewController(digitalInvoiceViewController, animated: true)
            } catch {
                // The extraction result didn't contain the information required
                // for a digital invoice to be created. Carry on as if Return
                // Assistant was disabled.
                handleAnalysis(with: extractionResult)
            }
            
        case .failure(let error):
            // Handle the error
        }
    }
}
```

In order to receive the result of the user's manipulation of the invoice, implement and set the `DigitalInvoiceViewControllerDelegate` delegate. It comprises a single `didFinish` function.
For instance:

```swift
extension ComponentAPICoordinator: DigitalInvoiceViewControllerDelegate {
    
    func didFinish(viewController: DigitalInvoiceViewController, invoice: DigitalInvoice) {
        
        handleAnalysis(with: invoice.extractionResult)
    }
}
```

### Customizing the UI

Detailed description of the customization options is available in the [Customization guide](customization-guide.html).
