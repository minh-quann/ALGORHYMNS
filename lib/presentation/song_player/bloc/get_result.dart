import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  bool isLoading = true;
  String fileContent = '';  // Biến lưu nội dung file
  List<String> _wrongNotes = []; // Danh sách các nốt hát sai

  // Hàm tải file compare_results.json từ server và lưu vào thư mục results
  Future<void> fetchAndSaveResults() async {
    try {
      // Gửi yêu cầu GET để tải file từ server
      final response = await http.get(Uri.parse('http://10.0.2.2:5000/get-results'));

      if (response.statusCode == 200) {
        // Lưu file vào thư mục trên thiết bị Android
        await saveFileToDevice(response.bodyBytes);
        // Sau khi lưu xong, đọc nội dung file
        await readFileContent();
        final data = jsonDecode(response.body);
        setState(() {
          _wrongNotes = List<String>.from(data);
          isLoading = false;
        });

        // Gửi phản hồi về server sau khi nhận file thành công
        await sendConfirmation('compare_results.json');
      } else {
        throw Exception('Failed to load results');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Hàm gửi phản hồi về server xác nhận đã nhận file
 Future<void> sendConfirmation(String fileName) async {
  try {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:5000/file-received'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': 'received'}),  // Gửi 'status' chứ không phải 'file'
    );

    if (response.statusCode == 200) {
      print('File confirmation sent successfully.');
    } else {
      print('Failed to send file confirmation.');
    }
  } catch (e) {
    print('Error sending confirmation: $e');
  }
}

  // Hàm lưu file vào thư mục results trong Android/data/com.quan.algorhymns
  Future<void> saveFileToDevice(List<int> fileBytes) async {
    try {
      // Lấy thư mục ngoài ứng dụng
      final directory = await getExternalStorageDirectory();
      if (directory == null) return;

      // Đường dẫn thư mục Android/data/com.quan.algorhymns/results
      final resultDirectory = Directory('${directory.path}/results');

      // Kiểm tra nếu thư mục chưa có thì tạo
      if (!await resultDirectory.exists()) {
        await resultDirectory.create(recursive: true); // Tạo thư mục nếu chưa có
      }

      // Tạo đường dẫn file và lưu file
      final filePath = '${resultDirectory.path}/compare_results.json';
      final file = File(filePath);

      // Lưu file vào thư mục
      await file.writeAsBytes(fileBytes);
      print('File saved to $filePath');
    } catch (e) {
      print('Error saving file: $e');
    }
  }

  Future<void> readFileContent() async {
    try {
      // Đường dẫn tới file compare_results.json
      final directory = await getExternalStorageDirectory();
      if (directory == null) return;

      final resultFilePath = '${directory.path}/results/compare_results.json';
      final file = File(resultFilePath);

      if (await file.exists()) {
        // Đọc file và phân tích JSON
        final content = await file.readAsString();
        setState(() {
          fileContent = content; // Lưu nội dung vào biến để hiển thị
        });
      } else {
        print("File not found");
      }
    } catch (e) {
      print('Error reading file: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAndSaveResults(); // Gọi hàm tải và lưu file khi màn hình được tạo
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết Quả Phân Tích'),
        backgroundColor: const Color.fromARGB(0, 209, 209, 209),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator() // Hiển thị khi đang tải
            : ListView.builder(  // Hiển thị các lỗi trong ListView
                itemCount: _wrongNotes.length,
                itemBuilder: (context, index) {
                  final error = _wrongNotes[index];
                  return _buildErrorCard(error);
                },
              ),
      ),
    );
  }

  // Hàm tạo Card hiển thị lỗi
  Widget _buildErrorCard(String error) {
    final parts = error.split(', ');  // Tách chuỗi thành các phần

    // Tách các phần thành Thời gian, Kỳ vọng, Thực tế
    final time = parts[0].replaceFirst('time: ', '');
    final expected = parts[1].replaceFirst('expected: ', '');
    final actual = parts[2].replaceFirst('actual: ', '');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: const CircleAvatar(
          backgroundColor: Colors.redAccent,
          child: Icon(
            Icons.music_note,
            color: Colors.white,
          ),
        ),
        title: Text(
          "Thời gian: $time",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Row(
          children: [
            const Text(
              "Kỳ vọng: ",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              expected,
              style: const TextStyle(color: Colors.green),
            ),
            const SizedBox(width: 16),
            const Text(
              "Thực tế: ",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              actual,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ],
        ),
      ),
    );
  }
}
