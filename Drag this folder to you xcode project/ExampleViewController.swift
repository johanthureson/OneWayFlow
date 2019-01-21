// Copy the code from within this viewcontroller to new viewcontrollers in your project,
// to get a fast start at implementing these new viewcontrollers.
//
// The code below involving the label variable, the number variable, and the buttonPress function
// is example code that needs to be replaced

import UIKit

class ExampleViewController: UIViewController, StateUpdatable {
    
    var oldState = StateStruct()
    var state = StateStruct()
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        action.subscribe(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        action.unsubscribe(self)
    }
    
    // Called e.g. when a button is pressed
    @IBAction func buttonPress(_ sender: Any) {
        action.increase()
    }
    
    // See that state.number is updated
    func updateState(to newState: StateStruct) {
        state = newState
        
        // functionality goes here,
        // often comparing newState with oldState to see if something needs to be done
        
        // only update if changed
        if state.number != oldState.number {
            label.text = String(state.number)
        }
        
        oldState = state
    }
    
}
