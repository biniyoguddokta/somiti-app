import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoTutorialScreen extends StatefulWidget {
  const VideoTutorialScreen({super.key});

  @override
  State<VideoTutorialScreen> createState() => _VideoTutorialScreenState();
}

class _VideoTutorialScreenState extends State<VideoTutorialScreen> {
  final List<Map<String, String>> videos = [
    {"title": "কিভাবে সদস্য যোগ করবেন", "url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ"}, 
    {"title": "কিভাবে জমা ও খরচ লিখবেন", "url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text("ভিডিও টিউটোরিয়াল"), backgroundColor: const Color(0xFF00796B), foregroundColor: Colors.white),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: videos.length,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(10),
              leading: Container(
                width: 100,
                height: 70,
                decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(10)),
                child: const Center(child: Icon(Icons.play_circle_fill, color: Color(0xFF00796B), size: 40)),
              ),
              title: Text(videos[index]['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("ভিডিও দেখতে ক্লিক করুন", style: TextStyle(color: Colors.grey)),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (c) => VideoPlayerScreen(videoUrl: videos[index]['url']!, title: videos[index]['title']!)));
              },
            ),
          );
        },
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;
  const VideoPlayerScreen({super.key, required this.videoUrl, required this.title});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl) ?? 'dQw4w9WgXcQ';
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), backgroundColor: const Color(0xFF00796B), foregroundColor: Colors.white),
      body: Column(
        children: [
          YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: const Color(0xFF00796B),
          ),
          const Padding(
            padding: EdgeInsets.all(15.0),
            child: Text("ভিডিওটি দেখে আপনি অ্যাপের এই ফিচারটি সম্পর্কে বিস্তারিত জানতে পারবেন।", style: TextStyle(fontSize: 16)),
          )
        ],
      ),
    );
  }
}