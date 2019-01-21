import Foundation

struct StaticFunc {
    
    /*
    Put the static functions needed here.
    - Try to move as much functionality from the ActionClass here as possible.
    Because static functions are easier to unit test.
    And because it keeps the Action class smaller.
    The functions in this struct can be divided into different files by extension.
     */
    
    static func increase(_ integer: Int) -> Int {
        return integer + 1
    }
    
}
