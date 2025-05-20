class JointAssessment {
  final String jointName;
  int painLevel; // 0-10
  String rangeOfMotion; // "Normal", "Limited", "Severely Limited"
  String notes;
  
  JointAssessment({
    required this.jointName,
    this.painLevel = 0,
    this.rangeOfMotion = "Normal",
    this.notes = "",
  });
}