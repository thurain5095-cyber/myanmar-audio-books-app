class Author {
  
  final String id;
  
  final String name;
  
  final String imageUrl;
  
  final String bio;
  

  
  Author({required this.id, required this.name, required this.imageUrl, required this.bio});
  

  
  factory Author.fromJson(Map<String, dynamic> json) {
    
    return Author(
      
      id: json['id'].toString(),
      
      name: json['name'],
      
      imageUrl: json['image_url'] ?? '',
      
      bio: json['bio'] ?? '',
      
    );
    
  }
  
}



class Book {
  
  final String id;
  
  final String title;
  
  final String authorId;
  
  final String audioUrl;
  
  final String? coverUrl;
  
  final String authorName;
  
  bool isDownloaded;
  
  String? localPath;
  

  
  Book({
    
    required this.id,
    
    required this.title,
    
    required this.authorId,
    
    required this.audioUrl,
    
    this.coverUrl,
    
    required this.authorName,
    
    this.isDownloaded = false,
    
    this.localPath,
    
  });
  

  
  factory Book.fromJson(Map<String, dynamic> json) {
    
    return Book(
      
      id: json['id'].toString(),
      
      title: json['title'],
      
      authorId: json['author_id'].toString(),
      
      audioUrl: json['audio_url'],
      
      coverUrl: json['cover_url'],
      
      authorName: json['authors'] != null ? json['authors']['name'] : 'Unknown',
      
    );
    
  }
  

  
  Map<String, dynamic> toMap() {
    
    return {
      
      'id': id,
      
      'title': title,
      
      'authorId': authorId,
      
      'audioUrl': audioUrl,
      
      'coverUrl': coverUrl,
      
      'authorName': authorName,
      
      'localPath': localPath,
      
    };
    
  }
  
}


























































