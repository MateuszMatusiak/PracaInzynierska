class ChatMessage {
  final String authorFirstname;
  final String authorLastname;
  final String authorNickname;
  final int authorId;
  final int id;
  final String message;
  final String time;

  ChatMessage(this.authorFirstname, this.authorLastname, this.authorNickname, this.authorId, this.id, this.message, this.time);

  ChatMessage.fromJson(Map<String, dynamic> json)
      : authorFirstname = json['author'] != null ? json['author']['firstName'] : "",
        authorLastname = json['author'] != null ? json['author']['lastName'] : "",
        authorNickname = json['author'] != null ? json['author']['nickname'] : "",
        authorId = json['author'] != null ? json['author']['id'] : "",
        id  = json['id'],
        message = json['message'],
        time = json['time'];

}

