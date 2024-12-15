class ClassModel {
  final String id;
  final String name;

  // Constructor of Class Models
  ClassModel({required this.id, required this.name});

  // Mapping classID with classname information retrieved from Firebase
  factory ClassModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ClassModel(
      id: id,
      name: data['classname'] ?? 'Unknown Class',
    );
  }
}
