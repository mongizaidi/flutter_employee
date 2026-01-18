class Employee {
  final int id;
  final String employeeName;
  final String employeeSalary;
  final String employeeAge;
  final String profileImage;

  Employee({
    required this.id,
    required this.employeeName,
    required this.employeeSalary,
    required this.employeeAge,
    required this.profileImage,
  });

  // Factory method to create an Employee object from JSON
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] is int ? json['id'] : int.parse(json['id']),
      employeeName: json['employee_name'],
      employeeSalary: json['employee_salary'],
      employeeAge: json['employee_age'],
      profileImage: json['profile_image'],
    );
  }
}
