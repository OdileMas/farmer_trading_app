class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String currentUserRole;
  final String targetUserId;
  final String targetUserRole;

  const ChatScreen({required this.currentUserId, required this.currentUserRole, required this.targetUserId, required this.targetUserRole});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}
