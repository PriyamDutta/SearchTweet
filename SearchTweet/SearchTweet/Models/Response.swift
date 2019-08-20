//
//	Response.swift


import Foundation

struct Response : Codable {

    let groups : [Group]?
	let headerFullLocation : String?
	let headerLocation : String?
	let headerLocationGranularity : String?
	let query : String?
	let suggestedBounds : SuggestedBound?
	let suggestedFilters : SuggestedFilter?
	let suggestedRadius : Int?
	let totalResults : Int?


}
