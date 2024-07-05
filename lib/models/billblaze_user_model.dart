abstract class BillblazeUserModel {
  String get uid;
  String get username;
  String get displayName;
  String get dpUrl;
  List<String> get friendList;
  List<String> get followerList;

  void getFriendList();
  void getFollowerList();

  BillblazeUserModel copyWith({
    String? uid,
    String? username,
    String? displayName,
    String? dpUrl,
    List<String>? friendList,
    List<String>? followerList,
  });

  Map<String, dynamic> toMap();

  factory BillblazeUserModel.fromMap(Map<String, dynamic> map) {
    // TODO: implement User.fromMap
    throw UnimplementedError();
  }

  String toJson();

  factory BillblazeUserModel.fromJson(String source) {
    // TODO: implement User.fromJson
    throw UnimplementedError();
  }

  @override
  String toString();

  @override
  bool operator ==(covariant BillblazeUserModel other);

  @override
  int get hashCode;
}
// ignore_for_file: public_member_api_docs, sort_constructors_first
//  class BillblazeUser {
//   final String uid;
//   final String username;
//   final String displayName;
//   final String? backUrl;
//   final String dpUrl;
//   final List<String> friendList;
//   final List<String> followerList;
  
//   void getFriendList(){}
//   void getFollowerList(){}

//   BillblazeUser({
//     required this.uid,
//     required this.username,
//     required this.displayName,
//     this.backUrl,
//     required this.dpUrl,
//     required this.friendList,
//     required this.followerList,
//   });

//   BillblazeUser copyWith({
//     String? uid,
//     String? username,
//     String? displayName,
//     String? backUrl,
//     String? dpUrl,
//     List<String>? friendList,
//     List<String>? followerList,
//   }) {
//     return BillblazeUser(
//       uid: uid ?? this.uid,
//       username: username ?? this.username,
//       displayName: displayName ?? this.displayName,
//       backUrl: backUrl ?? this.backUrl,
//       dpUrl: dpUrl ?? this.dpUrl,
//       friendList: friendList ?? this.friendList,
//       followerList: followerList ?? this.followerList,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return <String, dynamic>{
//       'uid': uid,
//       'username': username,
//       'displayName': displayName,
//       'backUrl': backUrl,
//       'dpUrl': dpUrl,
//       'friendList': friendList,
//       'followerList': followerList,
//     };
//   }

//   factory BillblazeUser.fromMap(Map<String, dynamic> map) {
//     return BillblazeUser(
//       uid: map['uid'] as String,
//       username: map['username'] as String,
//       displayName: map['displayName'] as String,
//       backUrl: map['backUrl'] != null ? map['backUrl'] as String : null,
//       dpUrl: map['dpUrl'] as String,
//       friendList: List<String>.from((map['friendList'] as List<String>),),
//       followerList: List<String>.from((map['followerList'] as List<String>),
//     )
//     );
//   }

//   String toJson() => json.encode(toMap());

//   factory BillblazeUser.fromJson(String source) => BillblazeUser.fromMap(json.decode(source) as Map<String, dynamic>);

//   @override
//   String toString() {
//     return 'BillblazeUser(uid: $uid, username: $username, displayName: $displayName, backUrl: $backUrl, dpUrl: $dpUrl, friendList: $friendList, followerList: $followerList)';
//   }

//   @override
//   bool operator ==(covariant BillblazeUser other) {
//     if (identical(this, other)) return true;
  
//     return 
//       other.uid == uid &&
//       other.username == username &&
//       other.displayName == displayName &&
//       other.backUrl == backUrl &&
//       other.dpUrl == dpUrl &&
//       listEquals(other.friendList, friendList) &&
//       listEquals(other.followerList, followerList);
//   }

//   @override
//   int get hashCode {
//     return uid.hashCode ^
//       username.hashCode ^
//       displayName.hashCode ^
//       backUrl.hashCode ^
//       dpUrl.hashCode ^
//       friendList.hashCode ^
//       followerList.hashCode;
//   }
// }

