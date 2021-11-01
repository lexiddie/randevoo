//
//  CategoriesProvider.swift
//  randevoo
//
//  Created by Lex on 22/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Hydra
import ObjectMapper
import SwiftyJSON

class CategoriesProvider {
    
    private let db = Firestore.firestore()
    
    func initiateCategory() {
        if let variations: [Variation] = FCache.get("gVariations"), !FCache.isExpired("gVariations") {
            gVariations = variations
        }
        
        if let categories: [Category] = FCache.get("gCategories"), !FCache.isExpired("gCategories") {
            gCategories = categories
        }
        
        if let subcategories: [Subcategory] = FCache.get("gSubcategories"), !FCache.isExpired("gSubcategories") {
            gSubcategories = subcategories
        }
        
        let _ = async { (_) -> (Bool) in
            gVariations = try await(self.fetchVariations())
            gCategories = try await(self.fetchCategories())
            gSubcategories = try await(self.fetchSubcategories())
            if gVariations.count > 0 && gCategories.count > 0 && gSubcategories.count > 0 {
                return true;
            } else {
                return false
            }
        }.then { (check) in
            if check {
                FCache.set(gVariations, key: "gVariations")
                FCache.set(gCategories, key: "gCategories")
                FCache.set(gSubcategories, key: "gSubcategories")
            }
//            let jsons = Mapper().toJSONString(gSubcategories, prettyPrint: true)!
//            print("Subcategories: \(jsons)")
        }
    }
    
    private func getCategory(categoryId: String) -> Category {
        if let category = gCategories.first(where: {$0.id == categoryId}) {
            return category
        } else {
            return Category(id: "", name: "")
        }
    }
    
    private func getVariations(ids: [String]) -> [Variation] {
        var tempList: [Variation] = []
        for i in ids {
            if let variation = gVariations.first(where: {$0.id == i}) {
                tempList.append(variation)
            }
        }
        return tempList
    }
    
    private func fetchSubcategories() -> Promise<[Subcategory]> {
        let subcategoryRef = db.collection("subcategories")
        return Promise<[Subcategory]>(in: .background) { (resolve, reject, _) in
            subcategoryRef
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting subcategory documents: \(err)")
                        reject(err)
                    } else {
                        var tempList: [Subcategory] = []
                        for document in querySnapshot!.documents {
                            let result = Mapper<SubcategoryDto>().map(JSONObject: document.data())!
                            let category = self.getCategory(categoryId: result.categoryId)
                            let variations = self.getVariations(ids: result.variations)
                            let subcategory = Subcategory(id: result.id, category: category, label: result.label, name: result.name, photoUrl: result.photoUrl, variations: variations)
                            tempList.append(subcategory)
                        }
                        resolve(tempList)
                    }
                }
        }
    }
    
//    private func fetchSubcategories() -> Promise<[Subcategory]> {
//        return Promise<[Subcategory]>(in: .background) { (resolve, reject, _) in
//            let records = Mapper<SubcategoryDto>().mapArray(JSONfile: "subcategories.json")!
//            var tempList: [Subcategory] = []
//            for record in records {
//                let category = self.getCategory(categoryId: record.categoryId)
//                let variations = self.getVariations(ids: record.variations)
//                let subcategory = Subcategory(id: record.id, category: category, label: record.label, name: record.name, photoUrl: record.photoUrl, variations: variations)
//                tempList.append(subcategory)
//            }
//            resolve(tempList)
//        }
//    }
    
    private func fetchCategories() -> Promise<[Category]> {
        let categoryRef = db.collection("categories")
        return Promise<[Category]>(in: .background) { (resolve, reject, _) in
            categoryRef
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting category documents: \(err)")
                        reject(err)
                    } else {
                        var tempList: [Category] = []
                        for document in querySnapshot!.documents {
                            let result = Mapper<CategoryDto>().map(JSONObject: document.data())!
                            let category = Category(id: result.id, name: result.name)
                            tempList.append(category)
                        }
                        resolve(tempList)
                    }
                }
        }
    }
    
//    private func fetchCategories() -> Promise<[Category]> {
//        return Promise<[Category]>(in: .background) { (resolve, reject, _) in
//            let records = Mapper<CategoryDto>().mapArray(JSONfile: "categories.json")!
//            var tempList: [Category] = []
//            for record in records {
//                let category = Category(id: record.id, name: record.name)
//                tempList.append(category)
//            }
//            resolve(tempList)
//        }
//    }
    
    private func fetchVariations() -> Promise<[Variation]> {
        let variationRef = db.collection("variations")
        return Promise<[Variation]>(in: .background) { (resolve, reject, _) in
            variationRef
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting variation documents: \(err)")
                        reject(err)
                    } else {
                        var tempList: [Variation] = []
                        for document in querySnapshot!.documents {
                            let result = Mapper<VariationDto>().map(JSONObject: document.data())!
                            let variation = Variation(id: result.id, label: result.label, name: result.name, values: result.values)
                            tempList.append(variation)
                        }
                        resolve(tempList)
                    }
                }
        }
    }
    
//    private func fetchVariations() -> Promise<[Variation]> {
//        return Promise<[Variation]>(in: .background) { (resolve, reject, _) in
//            let records = Mapper<VariationDto>().mapArray(JSONfile: "variations.json")!
//            var tempList: [Variation] = []
//            for record in records {
//                let variation = Variation(id: record.id, label: record.label, name: record.name, values: record.values)
//                tempList.append(variation)
//            }
//            resolve(tempList)
//        }
//    }
    
    
    func dispatchData() {
        let records1 = Mapper<SubcategoryDto>().mapArray(JSONfile: "subcategories.json")!
//        print("records1.count", records1.count)
//        let jsons = Mapper().toJSONString(records1, prettyPrint: true)!
//        print("Records: \(jsons)")
        for record in records1 {
            dispatchSubcategory(data: record)
        }
        
        let records2 = Mapper<VariationDto>().mapArray(JSONfile: "variations.json")!
//        print("records2.count", records2.count)
        for record in records2 {
            dispatchVariation(data: record)
        }
    }
    
    private func dispatchSubcategory(data: SubcategoryDto)  {
//        print("This function is running")
        let subcategoryRef = db.collection("subcategories")
        subcategoryRef.document(data.id).setData(data.toJSON()) { err in
            if let err = err {
                print("Error writing Subcategory: \(err)")
            } else {
                print("Subcategory successfully written!")
            }
        }
    }
    
    private func dispatchVariation(data: VariationDto)  {
        let variationRef = db.collection("variations")
        variationRef.document(data.id).setData(data.toJSON()) { err in
            if let err = err {
                print("Error writing Variation: \(err)")
            } else {
                print("Variation successfully written!")
            }
        }
    }
}
