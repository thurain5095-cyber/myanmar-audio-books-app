import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/bunny_service.dart';
import '../services/download_service.dart';

class AppProvider with ChangeNotifier {
  final BunnyService _bunnyService = BunnyService();
  final DownloadService _downloadService = DownloadService();
  
  List<Author> authors = [];
  List<Book> downloadedBooks = [];
  bool isDarkMode = false;
  bool isLoading = false;

  AppProvider() {
    _loadSettings();
    fetchAuthorsAndBooks();
    _loadDownloadedBooks();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    isDarkMode = !isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
    notifyListeners();
  }

  Future<void> fetchAuthorsAndBooks() async {
    isLoading = true;
    notifyListeners();
    try {
      authors = await _bunnyService.fetchAuthorsAndBooks();
    } catch (e) {
      print('Error fetching data from Bunny.net: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> _loadDownloadedBooks() async {
    // Placeholder for actual local storage logic
  }

  Future<void> refreshDownloads() async {
    notifyListeners();
  }
}
