class Boxer {
  final int id;
  final String boxerId;
  final String name;
  final String gender;
  final String? birthdate;
  final int age;
  final String nation;
  final String clubName;
  final String? photoUrl;
  final int totalFights;
  final int won;
  final int lost;
  final int cancelled;
  final String? weightClass;

  const Boxer({
    required this.id,
    required this.boxerId,
    required this.name,
    required this.gender,
    this.birthdate,
    required this.age,
    required this.nation,
    required this.clubName,
    this.photoUrl,
    required this.totalFights,
    required this.won,
    required this.lost,
    required this.cancelled,
    this.weightClass,
  });

  factory Boxer.fromJson(Map<String, dynamic> json) {
    // /boxer/me gibt data.boxer + data.stats zurück
    final fighter = json['fighter'] as Map<String, dynamic>? ?? json;
    final stats   = json['stats']   as Map<String, dynamic>? ?? {};

    return Boxer(
      id:         fighter['id'] ?? json['id'] ?? 0,
      boxerId:    fighter['boxer_id']?.toString() ?? json['boxer_id']?.toString() ?? '',
      name:       fighter['name']?.toString() ?? json['name']?.toString() ?? '',
      gender:     fighter['gender']?.toString() ?? 'm',
      birthdate:  fighter['birthdate']?.toString(),
      age:        fighter['age'] ?? 0,
      nation:     fighter['nation']?.toString() ?? '',
      clubName:   fighter['club']?.toString() ?? json['club_name']?.toString() ?? '',
      photoUrl:   _fixUrl(fighter['photo_url']?.toString() ?? json['photo_url']?.toString()),
      totalFights: stats['total'] ?? fighter['previous_battles'] ?? 0,
      won:         stats['won']       ?? 0,
      lost:        stats['lost']      ?? 0,
      cancelled:   stats['cancelled'] ?? 0,
      weightClass: fighter['weight_class_name']?.toString(),
    );
  }

  static String? _fixUrl(String? url) =>
      url?.replaceAll('hauptserver', 'treimytechlab.de');

  String get flagEmoji {
    if (nation.length != 2) return '';
    return nation.toUpperCase().runes
        .map((r) => String.fromCharCode(r + 0x1F1A5))
        .join();
  }

  String get genderLabel => switch (gender) {
    'w' => 'Weiblich',
    'x' => 'Divers',
    _   => 'Männlich',
  };
}
