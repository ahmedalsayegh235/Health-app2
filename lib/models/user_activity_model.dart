class UserActivity {
  final String title;
  final String time;
  final String icon;
  final int iconColor;

  UserActivity({
    required this.title,
    required this.time,
    required this.icon,
    required this.iconColor,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'time': time,
        'icon': icon,
        'iconColor': iconColor,
      };

  factory UserActivity.fromJson(Map<String, dynamic> json) {
    return UserActivity(
      title: json['title'],
      time: json['time'],
      icon: json['icon'],
      iconColor: json['iconColor'],
    );
  }
}
