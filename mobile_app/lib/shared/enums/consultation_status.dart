enum ConsultationStatus {
  notStarted('not_started'),
  inProgress('in_progress'),
  paused('paused'),
  completed('completed'),
  cancelled('cancelled');

  const ConsultationStatus(this.value);
  final String value;

  static ConsultationStatus fromString(String value) {
    return ConsultationStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ConsultationStatus.notStarted,
    );
  }
}