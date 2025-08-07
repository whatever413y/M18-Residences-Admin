class Admin {
  final String username;

  Admin({required this.username});

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(username: json['username']);
  }

  Map<String, dynamic> toJson() => {'username': username};
}
