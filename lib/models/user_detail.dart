class UserDetail {
  final String name;
  final String email;
  final String mobileNo;
  final String residentialAddress;
  final String courseName;
  final String batchName;
  final String etId;
  final String visaType;
  final String dob;
  final String passportNumber;
  final String status;
  // Adding new fields
  final String image;
  final String gender;
  final String birthResidentialAddress;
  final String postCode;
  final String passportExpiryDate;
  final String commencementDate;
  final String countryOfBirth;
  final String birthStateId;
  final String currentStateId;
  final String timeSlot;
  final String batchOtherName;
  final String isAusPermanentResident;
  final String countryOfLiving;
  final String eContactName;
  final String relation;
  final String eContactNo;
  

  UserDetail({
    required this.name,
    required this.email,
    required this.mobileNo,
    required this.residentialAddress,
    required this.courseName,
    required this.batchName,
    required this.etId,
    required this.visaType,
    required this.dob,
    required this.passportNumber,
    required this.status,
    required this.image,
    required this.gender,
    required this.birthResidentialAddress,
    required this.postCode,
    required this.passportExpiryDate,
    required this.commencementDate,
    required this.countryOfBirth,
    required this.birthStateId,
    required this.currentStateId,
    required this.timeSlot,
    required this.batchOtherName,
    required this.isAusPermanentResident,
    required this.countryOfLiving,
    required this.eContactName,
    required this.relation,
    required this.eContactNo,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] as Map<String, dynamic>;
    
    return UserDetail(
      name: userData['name']?.toString() ?? '',
      email: userData['email']?.toString() ?? '',
      mobileNo: userData['mobile_no']?.toString() ?? '',
      residentialAddress: userData['residential_address']?.toString() ?? '',
      courseName: userData['course_name']?.toString() ?? '',
      batchName: userData['batch_name']?.toString() ?? '',
      etId: userData['et_id']?.toString() ?? '',
      visaType: userData['visa_type']?.toString() ?? '',
      dob: userData['dob']?.toString() ?? '',
      passportNumber: userData['passport_number']?.toString() ?? '',
      status: userData['status']?.toString() ?? '',
      // Mapping new fields
      image: userData['image']?.toString() ?? '',
      gender: userData['gender']?.toString() ?? '',
      birthResidentialAddress: userData['birth_residential_address']?.toString() ?? '',
      postCode: userData['post_code']?.toString() ?? '',
      passportExpiryDate: userData['passport_expiry_date']?.toString() ?? '',
      commencementDate: userData['commencement_date']?.toString() ?? '',
      countryOfBirth: userData['country_of_birth']?.toString() ?? '',
      birthStateId: userData['birth_state_id']?.toString() ?? '',
      currentStateId: userData['current_state_id']?.toString() ?? '',
      timeSlot: userData['time_slot_id']?.toString() ?? '',
      batchOtherName: userData['batch_other_name']?.toString() ?? '',
      isAusPermanentResident: userData['is_aus_permanent_resident']?.toString() ?? '',
      countryOfLiving: userData['country_of_living']?.toString() ?? '',
      eContactName: userData['e_contact_name']?.toString() ?? '',
      relation: userData['relation']?.toString() ?? '',
      eContactNo: userData['e_contact_no']?.toString() ?? '',
    );
  }
}



















// class UserDetail {
//   final String name;
//   final String email;
//   final String mobileNo;
//   final String residentialAddress;
//   final String courseName;
//   final String batchName;
//   final String etId;
//   final String visaType;
//   final String dob;
//   final String passportNumber;
//   final String status;

//   UserDetail({
//     required this.name,
//     required this.email,
//     required this.mobileNo,
//     required this.residentialAddress,
//     required this.courseName,
//     required this.batchName,
//     required this.etId,
//     required this.visaType,
//     required this.dob,
//     required this.passportNumber,
//     required this.status,
//   });

//   factory UserDetail.fromJson(Map<String, dynamic> json) {
//     final userData = json['user'] as Map<String, dynamic>;
    
//     return UserDetail(
//       name: userData['name']?.toString() ?? '',
//       email: userData['email']?.toString() ?? '',
//       mobileNo: userData['mobile_no']?.toString() ?? '',
//       residentialAddress: userData['residential_address']?.toString() ?? '',
//       courseName: userData['course_name']?.toString() ?? '',
//       batchName: userData['batch_name']?.toString() ?? '',
//       etId: userData['et_id']?.toString() ?? '',
//       visaType: userData['visa_type']?.toString() ?? '',
//       dob: userData['dob']?.toString() ?? '',
//       passportNumber: userData['passport_number']?.toString() ?? '',
//       status: userData['status']?.toString() ?? '',
//     );
//   }
// }