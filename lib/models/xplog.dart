class XPLog {
  int earnedXP;
  String reason;
  String date;

  XPLog({
    required this.earnedXP,
    required this.reason,
    required this.date,
  });

  factory XPLog.fromSnapshot(Map<String, dynamic> data) {
    return XPLog(
      earnedXP: data['earnedXP'],
      reason: data['reason'],
      date: data['date'],
    );
  }

  Map<String, dynamic> toSnapshot() {
    return {
      'earnedXP': earnedXP,
      'reason': reason,
      'date': date,
    };
  }
}
