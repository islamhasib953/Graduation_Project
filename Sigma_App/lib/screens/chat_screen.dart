import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:segma/cubits/selected_child_cubit.dart';
import 'package:segma/models/doctor_model.dart';
import 'package:segma/services/chat_service.dart';
import 'package:segma/services/doctor_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
// حذف الـ imports الغير مستخدمة زي web_socket_channel

class ChatScreen extends StatefulWidget {
  final String childId;
  final String doctorId;

  const ChatScreen({required this.childId, required this.doctorId, super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  XFile? _selectedFile;

  @override
  void initState() {
    super.initState();
    _loadChat();
    _connectWithRetry();
  }

  Future<void> _connectWithRetry() async {
    int attempts = 0;
    const maxAttempts = 3;
    while (attempts < maxAttempts) {
      try {
        ChatService.initializeSocket(widget.childId, widget.doctorId); // استبدال connect بـ initializeSocket
        ChatService.getMessagesNotifier().addListener(_updateMessages); // استخدام ValueNotifier
        break;
      } catch (e) {
        attempts++;
        print('Connection attempt $attempts failed: $e');
        if (attempts == maxAttempts) {
          print('Max connection attempts reached');
        }
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  void _updateMessages() {
    if (mounted) {
      setState(() {
        _messages = List.from(ChatService.getMessagesNotifier().value); // تحديث الـ messages من ValueNotifier
      });
    }
  }

  Future<void> _loadChat() async {
    setState(() => _isLoading = true);
    try {
      final history = await ChatService.getChatHistory(widget.childId, widget.doctorId);
      if (mounted) {
        setState(() {
          _messages = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading chat history: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadFile() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        print('Selected file path: ${pickedFile.path}');
        setState(() {
          _selectedFile = pickedFile;
        });
      } else {
        print('No file selected');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  void _sendMessage() {
    final message = _controller.text.trim();
    final sender = context.read<SelectedChildCubit>().state == widget.childId ? 'child' : 'doctor';
    print('Send attempt - Message: "$message", File: $_selectedFile, Sender: $sender');
    if (message.isNotEmpty || _selectedFile != null) {
      ChatService.sendMessage(widget.childId, widget.doctorId, message, file: _selectedFile, sender: sender).then((_) {
        setState(() {
          _controller.clear();
          _selectedFile = null;
        });
        print('Message sent successfully');
      }).catchError((e) {
        print('Send error: $e');
      });
    } else {
      print('Send failed - No content or file');
    }
  }

  @override
  void dispose() {
    ChatService.getMessagesNotifier().removeListener(_updateMessages); // إزالة الـ Listener
    ChatService.disconnect();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: DoctorService.getDoctorDetails(widget.childId, widget.doctorId),
      builder: (context, snapshot) {
        String doctorName = 'Unknown Doctor';
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data!['status'] == 'success' && snapshot.data!['data'] != null) {
            final doctor = Doctor.fromJson(snapshot.data!['data']['doctor']);
            doctorName = '${doctor.firstName ?? 'Unknown'} ${doctor.lastName ?? ''}'.trim();
          } else if (snapshot.hasError) {
            print('Error fetching doctor details: ${snapshot.error}');
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Chat with $doctorName'),
          ),
          body: Column(
            children: [
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _messages.isEmpty
                        ? const Center(child: Text('No messages yet'))
                        : ListView.builder(
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final message = _messages[index];
                              final isSender = message['sender'] == (context.read<SelectedChildCubit>().state == widget.childId ? 'child' : 'doctor');
                              final date = DateTime.parse(message['timestamp']).toLocal();
                              final prevDate = index > 0 ? DateTime.parse(_messages[index - 1]['timestamp']).toLocal() : null;
                              return Column(
                                crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  if (prevDate == null || !DateFormat('yyyy-MM-dd').format(date).contains(DateFormat('yyyy-MM-dd').format(prevDate)))
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Text(DateFormat('yyyy-MM-dd').format(date), style: TextStyle(color: Colors.grey)),
                                    ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      color: isSender ? Colors.blue[100] : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (message['media'] != null)
                                          message['media'].contains(RegExp(r'\.(jpg|jpeg|png|gif|pdf|doc|docx)$', caseSensitive: false))
                                              ? Image.network(message['media'], width: 200, errorBuilder: (context, error, stackTrace) {
                                                  print('Error loading media: $error');
                                                  return const Text('Failed to load media');
                                                })
                                              : GestureDetector(
                                                  onTap: () => print('Download File clicked: ${message['media']}'),
                                                  child: Text('Download File', style: TextStyle(color: Colors.blue)),
                                                )
                                        else
                                          Text(message['content'] ?? ''),
                                        Text(DateFormat('HH:mm').format(date), style: TextStyle(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
              ),
              if (_selectedFile != null)
                Container(
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _selectedFile!.name.contains(RegExp(r'\.(jpg|jpeg|png|gif)$'))
                          ? Image.file(File(_selectedFile!.path), width: 50, height: 50, errorBuilder: (context, error, stackTrace) {
                              print('Error loading preview image: $error');
                              return Text(_selectedFile!.name);
                            })
                          : Text(_selectedFile!.name),
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _selectedFile = null),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(child: TextField(controller: _controller, decoration: InputDecoration(hintText: 'Type a message...'))),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: (_controller.text.isNotEmpty || _selectedFile != null) ? _sendMessage : null,
                      color: (_controller.text.isNotEmpty || _selectedFile != null) ? Colors.blue : Colors.grey,
                    ),
                    IconButton(
                      icon: const Icon(Icons.attach_file),
                      onPressed: _uploadFile,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}