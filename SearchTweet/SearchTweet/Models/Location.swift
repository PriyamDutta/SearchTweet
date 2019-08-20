//
//	Location.swift


import Foundation

struct Location : Codable {

	let address : String?
	let cc : String?
	let country : String?
	let distance : Int?
	let formattedAddress : [String]?
	let labeledLatLngs : [LabeledLatLng]?
	let lat : Float?
	let lng : Float?


}
