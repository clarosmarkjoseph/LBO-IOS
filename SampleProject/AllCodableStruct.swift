//
//  MainMenuResult.swift
//  SampleProject
//
//  Created by Paolo Hilario on 5/21/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import Foundation

struct MainMenuResponse:Codable{
    let arrayBanner:[ArrayBanner]?
    let arrayServices:[ArrayServices]?
    let arrayPackage:[ArrayPackage]?
    let arrayProducts:[ArrayProducts]?
    let arrayBranch:[ArrayBranch]?
    let arrayCommercial:[ArrayCommercial]?
    let versions:Versions?
}
struct ArrayCommercial:Codable{
    let id:Int?
}

struct Versions:Codable{
    let version_banner:Double?
    let version_branches:Double?
    let version_commercial:Double?
    let version_services:Double?
    let version_packages:Double?
    let version_products:Double?
}

struct ArrayBanner:Codable{
    let image:String?
}

struct ArrayServices:Codable{
    let id:Int?
    let service_code:String?
    let service_gender:String?
    let service_minutes:Int?
    let service_price:Double?
    let service_type_id:Int?
    let service_data:String?
    let is_active:Int?
    let service_package_id:Int?
    let created_at:String?
    let updated_at:String?
    let service_name:String?
    let service_description:String?
    let service_picture:String?
    let service_type_data:String?
}
struct ArrayPackage:Codable{
    let id:Int?
    let package_name:String?
    let package_desc:String?
    let package_image:String?
    let package_gender:String?
    let package_services:[Int]?
    let package_duration:Int?
    let package_price:Double?
    let service_package_id:Int?
}
struct ArrayProducts:Codable{
    let id:Int?
    let product_code:String?
    let product_variant:String?
    let product_size:String?
    let product_price:Double?
    let product_data:String?
    let is_active:Int?
    let product_group_id:Int?
    let created_at:String?
    let product_group_name:String?
    let product_picture:String?
    let product_description:String?
}

//branch Details
struct ArrayBranch:Codable{
    let id:Int?
    let branch_name:String?
    let rooms_count:Int?
    let branch_address:String?
    let branch_data:Branch_Data?
    let services:[Int]?
    let products:[Int]?
    let branch_contact:String?
    let map_coordinates:Branch_Coordinates?
    let branch_pictures:String?
    let branch_email:String?
    let branch_contact_person:String?
    let branch_classification:String?
    let payment_methods:String?
    let welcome_message:String?
    let schedules:[Branch_Schedule]?
    var estimated_distance:Double?      = 0.0
    var estimated_travel_time:String?   = "0"
}
struct Branch_Data:Codable {
    let ems_id:Int?
    let type:String?
    let extension_minutes:Int?
}
struct Branch_Coordinates:Codable {
    let lat:Float?
    let long:Float?
//    let branch_distance_in_meter:Double? = 0.0
//    let branch_travel_time:String? = "0 mins"
}

struct IterateBranchSchedule:Codable{
    let branch:[Branch_Schedule]?
    let technician:[ArrayTechnician]?
    let transactions:[StructTransactionQueuing]?
}

struct StructTransactionQueuing:Codable{
    let transaction_datetime:String?
    let duration:Int?
    let technician_id:Int?
}

//
/// Model of schedules of branches
//
struct Branch_Schedule:Codable {
    let date_start:String?
    let date_end:String?
    let schedule_type:String?
    let schedule_data:[Start_End]?
}

struct Start_End:Codable {
    var start:String?
    var end:String?
}

struct ArrayTechnician:Codable{
    let id:Int?
    let employee_id:String?
    let schedule:Start_End?
    let name:String?
    let type:String?
    let appointment:[Technician_Appointment]?
}

struct Technician_Appointment:Codable{
    let sched_appointment_start:String?
    let sched_appointment_end:String?
}
//
///end Model of schedules of branches
//


//
/// Model of app First load
//
struct AppFirstLoadVersion:Codable{
    let ifUpdated:Bool?
    let isValidToken:Bool?
    let arrayProfile:ObjectUserAccount?
}



//
///user details start
//
struct ObjectUserAccount:Codable{
    
    var id:Int?
    var email:String?
    var username:String?
    var first_name:String?
    var last_name:String?
    var middle_name:String?
    var birth_date:String?
    var user_mobile:String?
    var gender:String?
    var level:Int?
    var user_address:String?
    var user_data:String?
    var device_data:String?
    var last_activity:String?
    var last_login:String?
    var is_client:Int?
    var is_confirmed:Int?
    var is_agreed:Int?
    var is_active:Int?
    var user_picture:String?
    var transaction_data:String?
    
    enum CodingKeys: String, CodingKey{
        case id = "id"
        case email = "email"
        case username = "username"
        case first_name = "first_name"
        case last_name = "last_name"
        case middle_name = "middle_name"
        case birth_date = "birth_date"
        case user_mobile = "user_mobile"
        case gender = "gender"
        case level = "level"
        case user_address = "user_address"
        case user_data = "user_data"
        case device_data = "device_data"
        case last_activity = "last_activity"
        case last_login = "last_login"
        case is_confirmed = "is_confirmed"
        case is_client = "is_client"
        case is_agreed = "is_agreed"
        case is_active = "is_active"
        case user_picture = "user_picture"
        case transaction_data = "transaction_data"
    }
}

struct ObjectUserData:Codable {
    var home_branch:Int?
    var premier_status:Int?
    var facebook_id:String?
    var boss_id:String?
    var premier_branch:DataTypeChecker?
}

struct ArrayUserDeviceData:Codable {
    var token:String?
    var type:String?
    var device_info:String?
    var registered:String?
    var last_activity:String?
    var unique_device_id:String?
}

//transaction summary
struct ArrayUserTransactionData:Codable {
    let transaction_id:DataTypeChecker?
    let date:String?
    let branch:String?
    let inv:DataTypeChecker?
    let services:[BossServiceFetched]?
    let gross_price:DataTypeChecker?
    let price_discount:DataTypeChecker?
    let net_amount:DataTypeChecker?
    let remarks:String?
}


struct BossServiceFetched:Codable {
    let item_id:DataTypeChecker?
    let item_name:String?
    var quantity:DataTypeChecker?
    var unit_price:DataTypeChecker?
    let item_unit:String?
    let sub_total:DataTypeChecker?
    
    enum CodingKeys: String, CodingKey {
        case item_id
        case item_name
        case quantity
        case unit_price
        case item_unit
        case sub_total
    }
}

enum DataTypeChecker: Codable {
    
    case int(Int), string(String),double(Double)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Int.self) {
            self = .int(x)
            return
        }
        if let x = try? container.decode(Double.self) {
            self = .double(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        
        throw DecodingError.typeMismatch(DataTypeChecker.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Quantity"))
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let x):
            print("INTEGER: \(x)")
            try container.encode(x)
        case .string(let x):
            print("STRING: \(x)")
            try container.encode(x)
        case .double(let x):
            print("DOUBLE: \(x)")
            try container.encode(x)
        }
    }
}


//
///Models of Appointment
//
struct LBOAppointmentData:Codable{
    let id:Int?
    let reference_no:String?
    let branch_id:Int?
    let client_id:Int?
    let technician_id:Int?
    let transaction_datetime:String?
    var transaction_status:String?
    let transaction_type:String?
    let platform:String?
    let booked_by_name:String?
    let booked_by_type:String?
    let waiver_data:AppointmentWaiverData?
    let created_at:String?
    let updated_at:String?
    let serve_time:String?
    let complete_time:String?
    let acknowledgement_data:AppointmentAcknowledgement?
    
}

struct AppointmentAcknowledgement:Codable{
    let signature:String?
}

struct AppointmentObject:Codable {
    let branch:LabelAndValue?
    let technician:LabelAndValue?
    let client:LabelAndValue?
    let services:[ArrayAppointmentService]?
    let products:[ArrayAppointmentProduct]?
    let platform:String?
    let transaction_date:String?
    let transaction_type:String?
}

struct LabelAndValue:Codable{
    let value:Int?
    let label:String
}

struct ArrayAppointmentService:Codable{
    let id:Int?
    let price:Double?
    let start:String
    let end:String
}

struct ArrayAppointmentProduct:Codable{
    let id:Int?
    let price:Double?
    let quantity:Int
}

struct StructServiceTypeData:Codable{
    let restricted:[Int]?
}

//
/// End of Models of Appointment
//
    


//
/// Model Transactions
//
struct GetTotalTransactions:Codable{
    
    var total_price:Double?
    var total_discount:Double?
    var minimum_amount:Double?
    var premier:TransactionLastPremiere?
}

struct TransactionLastPremiere:Codable{
    let id:Int?
    let reference_no:String?
    let status:String?
    let remarks:String?
    let application_type:String?
}

//
/// Model Premiere Loyalty Card(Array) & Transaction Request
//
struct PremiereAndRequest:Codable{
    let application:[PremiereLoyaltyCardList]?
    let request:[TransactionRequest]?
}

struct PremiereLoyaltyCardList:Codable{
    
    let id:Int?
    let client_id:Int?
    let branch_id:Int?
    let application_type:String?
    let platform:String?
    let status:String?
    let reference_no:String?
    let remarks:String?
    let branch_name:String?
    let created_at:String?
    let date_applied:String?
    let plc_data:PLC_Data?
}

struct PLC_Data:Codable{
    let reason:String?
}

struct TransactionRequest:Codable{
    
    let id:Int?
    let client_id:Int?
    let status:String?
    let processed_date:String?
    let plc_review_request_data:String?
    let message:String?
    let remarks:String?
    let created_at:String?
    var valid_id_url:String? = ""
    let name:String?
    let updated_by:String?
    let processed_date_formatted:String?
    
}

struct PLCReviewDataStruct:Codable{
    let boss_id:String?
    let transactions:[PLCReviewTransactionStruct]?
    
}

struct PLCReviewTransactionStruct:Codable{
    let last_transaction:ArrayUserTransactionData?
    
}

//
///Models of Promotions
//
struct PromotionStruct:Codable {
    let id:Int?
    let title:String?
    let type:String?
    let description:String?
    let promo_picture:String?
    let date_start:String?
    let date_end:String?
    let branches:[Int]?
    let created_at:String?
//    let promotions_data:String?
    let posted_by_name:String?
}

struct FAQResultStruct:Codable {
    let questions:[FAQQuestionStruct]?
    let category:[FAQCategoryStruct]?
}

struct FAQQuestionStruct:Codable{
    let id:Int?
    let question:String?
    let answer:String?
    let description:String?
    let order:Int?
    let category:String?
}

struct FAQCategoryStruct:Codable{
    let image:String?
    let title:String?
    let category_id:Int?
}


struct AppointmentList:Codable{
    let id:Int?
    let reference_no:String?
    let branch_id:Int?
    let branch_name:String?
    let technician_name:String?
    let client_id:Int?
    let technician_id:Int?
    let transaction_datetime:String?
    var transaction_status:String?
    let transaction_type:String?
    let platform:String?
    let booked_by_name:String?
    let booked_by_type:String?
    let waiver_data:AppointmentWaiverData?
    let created_at:String?
    let updated_at:String?
    let serve_time:String?
    let complete_time:String?
    let acknowledgement_data:AppointmentAcknowledgement?
    var items:[AppointmentItemList]?
}

struct AppointmentItemList:Codable{
    let id:Int?
    let transaction_id:Int?
    let item_id:Int?
    let item_type:String?
    let amount:Double?
    let quantity:Int?
    let book_start_time:String?
    let book_end_time:String?
    let serve_time:String?
    let complete_time:String?
    var item_status:String?
    let created_at:String?
    let item_name:String?
    let item_image:String?
    let item_duration:Int?
    let item_info:ItemListInfo?
    var item_data:ItemData?
}

struct ItemData:Codable{
    var cancel_reason:String?
    var cancel_datetime:String?
    var cancel_by_name:String?
    var cancel_by_id:Int?
    var cancel_by_type:String?
}

struct ItemListInfo:Codable{
    let size:String?
    let variant:String?
}

struct AppointmentWaiverData:Codable{
    let signature:String?
}

struct BranchObjectRatingResult:Codable{
    let totalReviews:Int?
    let totalRatings:Double?
    let arrayRating:[Int]?
    let distance:Double?
    let duration:String?
    let arrayReview:[ArrayReviewStruct]?
    let offset:Int?
}

struct ArrayReviewStruct:Codable{
    let id:Int?
    let transaction_id:Int?
    let rating:Int?
    let feedback:String?
    let created_at:String?
    let review_status:String?
    let username:String?
    let first_name:String?
    let user_picture:String?
}

struct ArrayQueuing:Codable{
    
    let total_duration:Int?
    let full_name:String?
    let first_name:String?
    let client_id:Int?
    let transaction_type:String?
    let platform:String?
    let technician_name:String?
    let transaction_datetime:String?
    let transaction_id:Int?
    let reference_no:String?
    let technician_id:Int?
    let ifClientSignedWaiver:Bool?
}

struct QueuingExpressResult:Codable{
    let calling:[QueuingFromExpress]?
    let serving:[QueuingFromExpress]?
}

struct QueuingFromExpress:Codable{
    let branch_id:Int?
    let status:String?
    let appointment_id:Int?
    let client_id:Int?
}

struct ChatResult:Codable{
    let allMessage:[ArrayChatThread]?
}
struct ArrayChatThread:Codable{
    
    var id:Int?
    var participant_ids:[Int]?
    var created_by_id:Int?
    var created_at:String?
    var updated_at:String?
    var thread_name:String?
    var user_image:String?
    var messages:[ArrayChatMessage]?
    
}

struct ArrayChatMessage:Codable{
    var id:Int?
    var sender_id:Int?
    var recipient_id:Int?
    var message_thread_id:Int?
    var is_closed:Int?
    var title:String? = ""
    var body:String?
    var message_data:String?
    var read_at:String?
    var created_at:String?
    var updated_at:String?
    var deleted_to_id:DataTypeChecker?
    var status:String? = "sent"
}

struct ChatMessageSent:Codable{
    var result:String?
    var thread_id:Int?
    var latestChatID:Int?
    var object_sent:ArrayChatMessage?
}

struct RequestChatThread:Codable{
    var last_activity:String?
    var thread_id:Int?
    var recipient_id:Int?
    var thread_details:ArrayChatThread?
}

struct FacebookLogin:Codable{
    
    let id:String? = ""
    let birthday:String? = ""
    let email:String? = ""
    let gender:String? = ""
    let first_name:String? = ""
    let middle_name:String? = ""
    let last_name:String? = ""
    let picture:FacbookPictureData?
}

struct FacbookPictureData:Codable{
    let data: FacbookPicture?
}
struct FacbookPicture:Codable{
    let url:String?
}

//struct PushNotificationObject:Codable{
//    let notification_type:String?
//    let title:String?
//    let message:String?
//    let id:Int?
//    let created_at:String?
//    let notification_data:PushNotificationData?
//}
//
//struct PushNotificationData:Codable{
//    let unique_id:Int?
//    let title:String?
//    let body:String?
//}

struct UserNotification:Codable{
    var id:Int?
    var notification_data:NotificationData?
    var notification_type:String?
    var created_at:String?
    var isRead:Int?
}

struct NotificationData:Codable{
    var title:String?
    var body:String?
    var unique_id:Int?
}

struct GetTechnicianRequest:Codable{
    let leave:[ArrayTechnicianLeave]?
}

struct ArrayTechnicianLeave:Codable{
    let request_data:ObjectTechnicianLeave?
}

struct ObjectTechnicianLeave:Codable{
    let date_start:String?
    let date_end:String?
    let status:String?
    let leave_type:String?
    let mode:String?
    let days:Int?
}







