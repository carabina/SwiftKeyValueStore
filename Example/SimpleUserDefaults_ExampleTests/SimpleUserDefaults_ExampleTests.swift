//
//  SimpleUserDefaults_ExampleTests.swift
//  SimpleUserDefaults_ExampleTests
//
//  Created by Yevgeniy Prokoshev on 23/07/2018.
//  Copyright © 2018 FutureWorkshops. All rights reserved.
//

import XCTest
@testable import SimpleUserDefaults

class Profile: NSObject, NSCoding {
    
    var name: String
    var age: Int
    
    init(name: String, age: Int) {
        self.age = age
        self.name = name
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "Profile.Name")
        aCoder.encode(age, forKey: "Profile.Age")
    }
    
     required convenience init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: "Profile.Name") as? String else { return nil }
        let age = aDecoder.decodeInteger(forKey: "Profile.Age")
        self.init(name: name, age: age)
    }
}

struct AnotherStruct: Codable, Hashable {
    var name: String
    var secondName: String
}

struct MyStruct: Codable, Hashable  {
    
    var name: String
    var secondName: String
    
    var codable: AnotherStruct
}


private var DefaultsKeyValueStore = UserDefaults.standard

class SimpleUserDefaults_ExampleTests: XCTestCase {
    
    func testCodableStruct() {
        let structKey = KeyValueStoreKey<MyStruct>(stringLiteral: "structValue")

        let user = MyStruct(name: "asd", secondName: "asdasd", codable: AnotherStruct(name: "asdad", secondName: "asdasd"))
        DefaultsKeyValueStore.save(user, forKey: structKey)

        XCTAssert(DefaultsKeyValueStore.get(forKey: structKey) == user)
    }
    
    func testInt() {
        let intKey = KeyValueStoreKey<Int>(stringLiteral: "intValue")
        DefaultsKeyValueStore.save(123, forKey: intKey)

        XCTAssert(DefaultsKeyValueStore.get(forKey: intKey) == 123)
    }
    
    func testArrayOfString() {
        
        let arrayOfStringsKey = KeyValueStoreKey<Array<String>>(stringLiteral: "arrayOfStringsKey")

        let stringsArray = ["123", "234", "String"]
        DefaultsKeyValueStore.save(stringsArray, forKey: arrayOfStringsKey)
        
        XCTAssert(DefaultsKeyValueStore.get(forKey: arrayOfStringsKey) == stringsArray)
    }
    
    func testSetOfInts() {
        let intsSetKey = KeyValueStoreKey<Set<Int>>(stringLiteral: "SetOfInt")

        let intSet = Set([123, 234, 456])
        DefaultsKeyValueStore.save(intSet, forKey: intsSetKey)
        
        XCTAssert(DefaultsKeyValueStore.get(forKey: intsSetKey) == intSet)
    }
    
    func testRegister () {
        let stringsArray = ["123", "234", "String"]
        
        let stringsArrayKey = KeyValueStoreKey<Array<String>>(stringLiteral: "StringsArray")
        DefaultsKeyValueStore.register(defaultValue: stringsArray, for: stringsArrayKey)

        XCTAssert(DefaultsKeyValueStore.get(forKey: stringsArrayKey) == stringsArray)
    }
    
    func testCodableSubscript() {
        
        let structsArray = KeyValueStoreKey<Array<MyStruct>>(stringLiteral: "StructsArray")
        
        let user = MyStruct(name: "asd", secondName: "asdasd", codable: AnotherStruct(name: "asdad", secondName: "asdasd"))
        DefaultsKeyValueStore.save([user], forKey: structsArray)
        
        let user_1 = MyStruct(name: "asd", secondName: "asdasd", codable: AnotherStruct(name: "asdad", secondName: "asdasd"))
        DefaultsKeyValueStore[structsArray]?.append(user_1)
        
        let newArray = DefaultsKeyValueStore[structsArray]
        
        XCTAssert(newArray?.count == 2)
    }
    
    func testNSCodingNotNill() {
        let profileKey = KeyValueStoreKey<Profile>(stringLiteral: "Profile")
        let profile = Profile(name: "Foo", age: 23)
        
        DefaultsKeyValueStore.save(profile, forKey: profileKey)
        guard let _ = DefaultsKeyValueStore.get(forKey: profileKey) else { XCTFail(); return }

    }
    
    func testNSCodingSame () {
        let profileKey = KeyValueStoreKey<Profile>(stringLiteral: "Profile")
        let profile = Profile(name: "Foo", age: 23)
        
        DefaultsKeyValueStore.save(profile, forKey: profileKey)
        guard let decodedProfile = DefaultsKeyValueStore.get(forKey: profileKey) else { XCTFail(); return}
        
        XCTAssert((decodedProfile.name == profile.name && decodedProfile.age == profile.age))
    }
    
    func testNSCodingSubscript () {
        let profileKey = KeyValueStoreKey<Profile>(stringLiteral: "Profile")
        let profile = Profile(name: "Foo", age: 23)
        
        DefaultsKeyValueStore[profileKey] = profile
        guard let decodedProfile = DefaultsKeyValueStore.get(forKey: profileKey) else { XCTFail(); return}

        XCTAssert((decodedProfile.name == profile.name && decodedProfile.age == profile.age))
    }
    
    
    func testResetStorage() {
        
        let profileKey = KeyValueStoreKey<Profile>(stringLiteral: "Profile")
        let profile = Profile(name: "Foo", age: 23)
        
        DefaultsKeyValueStore[profileKey] = profile
        
        guard let decodedProfile = DefaultsKeyValueStore.get(forKey: profileKey) else { XCTFail(); return}
        XCTAssert((decodedProfile.name == profile.name && decodedProfile.age == profile.age))
        
        DefaultsKeyValueStore.resetStorage()
        guard let _ = DefaultsKeyValueStore.get(forKey: profileKey) else { return }
        XCTFail();
    }
    
    func testDefaultPrimitiveValue() {
        let intKeyWithDefaultValue = KeyValueStoreKey<Int>(stringLiteral: "IntWithDefault", defaultValue: 222)
        guard let decodedIntDefault = DefaultsKeyValueStore.get(forKey: intKeyWithDefaultValue) else { XCTFail(); return}
        
        XCTAssert(decodedIntDefault == 222)
    }
    
    
    func testDefaultStructValue() {
        let DefaultStruct = AnotherStruct(name: "DefaultName", secondName: "DefaultSecondName")
        let structKeyWithDefaultValue = KeyValueStoreKey<AnotherStruct>(stringLiteral: "defaultStruct", defaultValue: DefaultStruct)
        
        guard let decodedStructDefault = DefaultsKeyValueStore.get(forKey: structKeyWithDefaultValue) else { XCTFail(); return}
        XCTAssert(decodedStructDefault.name == "DefaultName" && decodedStructDefault.secondName == "DefaultSecondName")
    }
}
