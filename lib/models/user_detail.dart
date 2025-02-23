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
    );
  }
}