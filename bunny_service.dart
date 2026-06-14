import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../utils/constants.dart';

class BunnyService {
  final String apiKey = Constants.bunnyApiKey;
  final String storageZoneName = Constants.bunnyStorageZone;
  final String pullZoneUrl = Constants.bunnyPullZone;
  final String storageEndpoint = 'https://storage.bunnycdn.com';

  Future<List<Author>> fetchAuthorsAndBooks() async {
    try {
      // Fetch all files from the root of the storage zone
      final response = await http.get(
        Uri.parse('$storageEndpoint/$storageZoneName/'),
        headers: {
          'AccessKey': apiKey,
          'accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> files = json.decode(response.body);
        Map<String, List<Book>> authorMap = {};

        for (var file in files) {
          // If it's an MP3 file, parse the filename to extract author
          if (file['IsDirectory'] == false && file['ObjectName'].toString().endsWith('.mp3')) {
            String fileName = file['ObjectName'];
            
            // Logic to extract author from filename: "Author Name - Title.mp3"
            String authorName = "အထွေထွေ"; // Default category
            String bookTitle = fileName.replaceAll('.mp3', '');

            if (fileName.contains(' - ')) {
              List<String> parts = fileName.split(' - ');
              authorName = parts[0].trim();
              bookTitle = parts.sublist(1).join(' - ').replaceAll('.mp3', '').trim();
            } else if (fileName.contains('-')) {
              List<String> parts = fileName.split('-');
              authorName = parts[0].trim();
              bookTitle = parts.sublist(1).join('-').replaceAll('.mp3', '').trim();
            }

            final book = Book(
              id: file['Guid'] ?? fileName,
              title: bookTitle,
              authorName: authorName,
              audioUrl: '$pullZoneUrl/$fileName',
              duration: (file['Length'] / (1024 * 1024)).toStringAsFixed(2) + " MB", // Using size as duration placeholder
              imageUrl: '', 
            );

            if (!authorMap.containsKey(authorName)) {
              authorMap[authorName] = [];
            }
            authorMap[authorName]!.add(book);
          }
          // If it's a directory, we can also treat it as an author (keeping existing logic)
          else if (file['IsDirectory'] == true) {
            String dirName = file['ObjectName'];
            List<Book> booksInDir = await _fetchBooksForAuthor(dirName);
            if (booksInDir.isNotEmpty) {
              if (!authorMap.containsKey(dirName)) {
                authorMap[dirName] = [];
              }
              authorMap[dirName]!.addAll(booksInDir);
            }
          }
        }

        return authorMap.entries.map((e) => Author(
          id: e.key,
          name: e.key,
          imageUrl: '', 
          books: e.value,
        )).toList();
      } else {
        throw Exception('Failed to load content from Bunny.net');
      }
    } catch (e) {
      print('Error fetching from Bunny.net: $e');
      return [];
    }
  }

  Future<List<Book>> _fetchBooksForAuthor(String authorName) async {
    try {
      final response = await http.get(
        Uri.parse('$storageEndpoint/$storageZoneName/$authorName/'),
        headers: {
          'AccessKey': apiKey,
          'accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> files = json.decode(response.body);
        List<Book> books = [];

        for (var file in files) {
          if (file['IsDirectory'] == false && file['ObjectName'].endsWith('.mp3')) {
            String fileName = file['ObjectName'];
            String title = fileName.replaceAll('.mp3', '');
            books.add(Book(
              id: '$authorName/$fileName',
              title: title,
              authorName: authorName,
              audioUrl: '$pullZoneUrl/$authorName/$fileName',
              duration: (file['Length'] / (1024 * 1024)).toStringAsFixed(2) + " MB",
              imageUrl: '', 
            ));
          }
        }
        return books;
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
