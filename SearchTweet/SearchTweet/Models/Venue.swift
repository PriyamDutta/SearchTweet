//
//	Venue.swift


import Foundation

struct Venue : Codable {

	let beenHere : BeenHere?
	let categories : [Category]?
	let contact : Contact?
    let hereNow : HereNow?
	let id : String?
    let location : Location?
	let name : String?
    let photos : Photo?
    let stats : Stat?
	let verified : Bool?


}
