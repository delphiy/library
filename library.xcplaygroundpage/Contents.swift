//: [Previous](@previous)

import Foundation

protocol MemberContract {
    func rent(item: Item) -> Result<Item, LibraryError>
    func removeItem(item: Item) -> Item
    func returnItem(item: Item) -> Item
    func charge(item: Item, charge: Float) -> Bool
    func charge(item: Item) -> Bool
}

protocol LibraryContract {
    func findWhereItem(itemRef: String) -> Member?
}

//For any new item we just added as enum
//Second approch is to creat class for each item and inhert from super class,
enum ItemType {
    case Book
    case CD
    case lifeOfBrainDVD
}

enum LibraryError: Error {
    case ReachMaxRental
}

class Library {
    var membersList = [Member]()
    var itemsList = [Item]()
    
    //Loop through member and find if item still rent it out
    func findWhereItem(itemRef: String) -> Member? {
        for member in membersList {
            let item = member.currentRentals().filter { $0.uniqueRef == itemRef }.first
            if item != nil {
                return member
            }
        }
        
        return nil
    }
}

class Member: MemberContract {
    let name: String
    private var _items = [Item]()
    private let _rentalMax = 5

    init(name: String) {
        self.name = name
    }
    
    var rentRemaining: Int {
        _rentalMax - _items.count
    }
    
    func rent(item: Item) -> Result<Item, LibraryError> {
        if(_items.count == _rentalMax) {
            return .failure(.ReachMaxRental)
        }
        
        _items.append(item)
        
        return .success(item)
    }
    
    func removeItem(item: Item) -> Item {
        _items.removeAll{ $0.uniqueRef == item.uniqueRef }
        return item
    }
    
    func returnItem(item: Item) -> Item {
        _items.removeAll{ $0.uniqueRef == item.uniqueRef }
        return item
    }
     
    func currentRentals() -> [Item] {
        return _items
    }
    
    func charge(item: Item, charge: Float) -> Bool {
        return true
    }
    
    func charge(item: Item) -> Bool {
        return true
    }
    
}

class Item {
    let itemType: ItemType
    let uniqueRef: String
    var charge: Float
    let maximumRentalPeriod: Int
    var lateReturnCharge: Float?
    
    init(itemType: ItemType, uniqueRef: String, charge: Float, maximumRentalPeriod: Int) {
        self.itemType = itemType
        self.uniqueRef = uniqueRef
        self.charge = charge
        self.maximumRentalPeriod = maximumRentalPeriod
    }
    
    func updateCharge(item: Item, newCharge: Float) -> Item {
        item.charge = newCharge
        return item
    }
}

//Test
//Create library
let library = Library()

//Create members
let brianMember = Member(name: "Brain Wilson")

//add to library
library.membersList.append(brianMember)

//Create item
let lifeOfBrainDVD = Item(itemType: .lifeOfBrainDVD, uniqueRef: "2", charge: 12.00, maximumRentalPeriod: 10)

//add to library
library.membersList.append(brianMember)

//rent item and charge without override charge
let result = brianMember.rent(item: lifeOfBrainDVD)
switch result {
    case .success(let item) :
        _ = brianMember.charge(item: item)
    case .failure(let error) :
        print(error)
}

//Find where is item if with member
if let withMember = library.findWhereItem(itemRef: "2") {
    print(withMember.name)
} else {
    print("In shelve")
}
