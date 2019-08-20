//
//	Item.swift


import Foundation

struct Item : Codable {

	let reasonName : String?
	let summary : String?
	let type : String?
    let reasons : Reason?
	let referralId : String?
    let venue : Venue?


}
