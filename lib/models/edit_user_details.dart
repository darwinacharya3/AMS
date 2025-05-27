class EditUserDetail {
  final String id;
  final String userId;
  final String studentId;
  final String name;
  final String email;
  final String mobileNo;
  final String gender;
  final String dob;
  final String countryOfBirth;
  final String birthStateId;
  final String birthResidentialAddress;
  final String commencementDate;
  final String signature;
  final String isAusPermanentResident;
  final String countryOfLiving;
  final String residentialAddress;
  final String postCode;
  final String visaType;
  final String currentStateId;
  final String passportNumber;
  final String passportExpiryDate;
  final String eContactName;
  final String relation;
  final String eContactNo;
  final String highestEducation;
  final String profileImage;
  final String status;
  
  // Using a map to make editableFields mutable
  final Map<String, bool> editableFields;

  EditUserDetail({
    required this.id,
    required this.userId,
    required this.studentId,
    required this.name,
    required this.email,
    required this.mobileNo,
    required this.gender,
    required this.dob,
    required this.birthStateId,
    required this.countryOfBirth,
    required this.birthResidentialAddress,
    required this.commencementDate,
    required this.signature,
    required this.isAusPermanentResident,
    required this.countryOfLiving,
    required this.residentialAddress,
    required this.postCode,
    required this.visaType,
    required this.currentStateId,
    required this.passportNumber,
    required this.passportExpiryDate,
    required this.eContactName,
    required this.relation,
    required this.eContactNo,
    required this.highestEducation,
    required this.profileImage,
    required this.status,
    Map<String, bool>? editableFields,
  }) : this.editableFields = editableFields ?? _defaultEditableFields();

  // Default editable fields - can be overridden by API response
  static Map<String, bool> _defaultEditableFields() {
    return {
      'name': false,           // Name not editable
      'email': false,          // Email not editable
      'mobileNo': true,
      'gender': true,
      'dob': true,
      'countryOfBirth': false, // Birth Country not editable
      'birthStateId': true,
      'birthResidentialAddress': true,
      'commencementDate': true,
      'signature': false,      // Digital Signature not editable
      'isAusPermanentResident': true,
      'countryOfLiving': true,
      'residentialAddress': true,
      'postCode': true,
      'visaType': false,       // Visa Type not editable
      'currentStateId': true,
      'passportNumber': false, // Passport Number not editable
      'passportExpiryDate': true,
      'eContactName': true,
      'relation': true,
      'eContactNo': true,
      'highestEducation': true,
      'profileImage': true,
    };
  }

  factory EditUserDetail.fromJson(Map<String, dynamic> json) {
    // Parse editable fields if available
    Map<String, bool>? editableFields;
    
    if (json.containsKey('editable_fields')) {
      editableFields = Map<String, bool>.from(json['editable_fields']);
    } else {
      // If editable_fields is not provided, use our default settings
      editableFields = _defaultEditableFields();
    }
    
    return EditUserDetail(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      studentId: json['student_id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobileNo: json['mobile_no'] ?? '',
      gender: json['gender']?.toString() ?? '1',
      dob: json['dob'] ?? '',
      countryOfBirth: json['country_of_birth']?.toString() ?? '',
      birthStateId: json['birth_state_id']?.toString() ?? '',
      birthResidentialAddress: json['birth_residential_address'] ?? '',
      commencementDate: json['commencement_date'] ?? '',
      signature: json['signature'] ?? '',
      isAusPermanentResident: json['is_aus_permanent_resident']?.toString() ?? '0',
      countryOfLiving: json['country_of_living']?.toString() ?? '',
      residentialAddress: json['residential_address'] ?? '',
      postCode: json['post_code'] ?? '',
      visaType: json['visa_type'] ?? '',
      currentStateId: json['current_state_id']?.toString() ?? '',
      passportNumber: json['passport_number'] ?? '',
      passportExpiryDate: json['passport_expiry_date'] ?? '',
      eContactName: json['e_contact_name'] ?? '',
      relation: json['relation'] ?? '',
      eContactNo: json['e_contact_no'] ?? '',
      highestEducation: json['highest_education'] ?? '',
      profileImage: json['profile_image'] ?? '',
      status: json['status']?.toString() ?? '1',
      editableFields: editableFields,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'student_id': studentId,
      'name': name,
      'email': email,
      'mobile_no': mobileNo,
      'gender': gender,
      'dob': dob,
      'country_of_birth': countryOfBirth,
      'birth_state_id': birthStateId,
      'birth_residential_address': birthResidentialAddress,
      'commencement_date': commencementDate,
      'signature': signature,
      'is_aus_permanent_resident': isAusPermanentResident,
      'country_of_living': countryOfLiving,
      'residential_address': residentialAddress,
      'post_code': postCode,
      'visa_type': visaType,
      'current_state_id': currentStateId,
      'passport_number': passportNumber,
      'passport_expiry_date': passportExpiryDate,
      'e_contact_name': eContactName,
      'relation': relation,
      'e_contact_no': eContactNo,
      'highest_education': highestEducation,
      'profile_image': profileImage,
      'status': status,
    };
  }
}