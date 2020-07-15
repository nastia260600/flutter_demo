class Project {
  final String login;
  final String avatar_url;
  final int id;

  Project._({this.login, this.avatar_url, this.id});

  factory Project.fromJson(Map<String, dynamic> json) {
    return new Project._(
      login: json['login'],
      avatar_url: json['avatar_url'],
      id: json['id'],
    );
  }
}