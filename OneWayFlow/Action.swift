import Foundation

let action = ActionClass(persistState: true)

class ActionClass: ActionClassParent {

    // Put the functions needed here

    func increase() {
        self.state.number = StaticFunc.increase(self.state.number)
    }
    
}
