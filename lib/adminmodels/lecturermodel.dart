class LecturerModel {
  final String id;
  final String name;
  // constructore of Lecture Model
  LecturerModel({required this.id, required this.name});
  // Mapping Lecturer's ID with their Username 
  factory LecturerModel.fromFirestore(Map<String, dynamic> data, String id) {
    return LecturerModel(
      id: id,
      name: data['username'] ?? 'Unknown Lecturer',
    );
  }
}
