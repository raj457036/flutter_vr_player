class EventMessage {
  final int readyState;
  final int event;
  final message;

  const EventMessage(this.readyState, this.event, this.message);

  EventMessage.fromJson(Map<String, dynamic> jsonMessage)
      : readyState = jsonMessage.containsKey('readyState')
            ? jsonMessage['readyState']
            : null,
        event = jsonMessage.containsKey('event') ? jsonMessage['event'] : null,
        message =
            jsonMessage.containsKey('message') ? jsonMessage['message'] : null;
}
