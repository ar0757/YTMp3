import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:media_scanner/media_scanner.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YTMp3',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16),
        ),
      ),
      home: const DownloaderScreen(),
    );
  }
}

class DownloaderScreen extends StatefulWidget {
  const DownloaderScreen({super.key});

  @override
  _DownloaderScreenState createState() => _DownloaderScreenState();
}

class _DownloaderScreenState extends State<DownloaderScreen> {
  final TextEditingController _urlController = TextEditingController();
  String _status = 'Ready';
  String _selectedQuality = '320K';
  double? _downloadProgress;

  // Replace with your CloudConvert API key
  final String _apiKey = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiNDVhNDRkNGM4MGNiMDIwMGM2MmM3NzIyZjAxNzcwOGU2MjRmZWZkMWRjYjA1ZTIwM2MxYjAyODFiZDY4OWU3OTZlOWZhZGYxNTg2OTk0YzgiLCJpYXQiOjE3NDM2OTYzODQuODUwODM5LCJuYmYiOjE3NDM2OTYzODQuODUwODQxLCJleHAiOjQ4OTkzNjk5ODQuODQ0OTU2LCJzdWIiOiI3MTUzMTc4NyIsInNjb3BlcyI6WyJ0YXNrLndyaXRlIiwid2ViaG9vay53cml0ZSIsInByZXNldC53cml0ZSIsInVzZXIud3JpdGUiLCJ0YXNrLnJlYWQiLCJ3ZWJob29rLnJlYWQiLCJwcmVzZXQucmVhZCJdfQ.S4mThTXlt0ovq033BCkjywgkdHynnCUpk751M1K2a46u4MeOqikVbz2pny0x6RC_8gQON8CF4gDMenMeUkL2CXIF4X8p-bTJAzJ_fnoK069AVD3r5T3y_UekjOtye1pf2lL-6sIPOQq6Qa86NYfcnmWpFbUJGyo8QdIZGoe96ihNWRr74JOIV9jdDGDys2nLOTYm1k3801mzqh0rVGsnvRiW3JB0qKfp3GjoaPpNSoR9gr8pR_tz1NeV1Y5Y0L0iYfbzNClt8Lt25UrSDhzk9wnQx0hIb2mRA01uw3O4H1v_KbLuAw57Ov1zrZmQ-lKHCfLFo8vh0364EGmtRSEqJFcsnTY5S4620BnRRg2sXjkMPG8D8MAKOCONdlm7UOte2xTMhE_TVTQ7ML16MojkroSbjMhdhhso5Ynjs8NXHpqUPgYgQ1dOO1mw7mKDwd_7Jx189NGTqRfCXWpr9NPAbX_D7PQDowL5naSQJXoRjfEqCuWpjF0K-lXW1H1xoj5FIGQZLb5JhXcNamhQF67tYMWETpAYn4_aQRZE0C_uKb7-tWzA34NbuvPR4ATS6n_Tjc-kZCkppj7MdRzjgXjAFqGiymmOBtj6TshtE8C0CEKQIXCc9n3919nB7I0Nq0gjUXIZwTN42p60S0NfoGcb0lu-q6vv8bexsaRhLzNoLSc';

  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid && (await _getAndroidVersion()) >= 33) {
      if (await Permission.manageExternalStorage.isDenied) {
        var status = await Permission.manageExternalStorage.request();
        if (status.isDenied) {
          return false;
        }
        return status.isGranted;
      }
    } else {
      if (await Permission.storage.isDenied) {
        var status = await Permission.storage.request();
        if (status.isDenied) {
          return false;
        }
        return status.isGranted;
      }
    }
    return true;
  }

  Future<int> _getAndroidVersion() async {
    // Placeholder; adjust based on your Samsung's Android version
    return 33;
  }

  Future<void> _downloadAndConvertAudio() async {
    String url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() {
        _status = 'Please enter a URL!';
        _downloadProgress = null;
      });
      return;
    }

    bool hasPermission = await _requestPermissions();
    if (!hasPermission) {
      setState(() {
        _status =
            'Storage permission denied. Please grant it in settings and try again.';
        _downloadProgress = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Storage permission is required to save files. Go to Settings > Apps > YTMp3 > Permissions.'),
          action: SnackBarAction(
            label: 'Open Settings',
            onPressed: () => openAppSettings(),
          ),
        ),
      );
      return;
    }

    setState(() {
      _status = 'Downloading...';
      _downloadProgress = 0.0;
    });

    try {
      var yt = YoutubeExplode();
      var video = await yt.videos.get(url);
      var streamInfo = (await yt.videos.streamsClient.getManifest(url))
          .audioOnly
          .withHighestBitrate();

      var stream = yt.videos.streamsClient.get(streamInfo);
      var appDir = await getExternalStorageDirectory();
      if (appDir == null) {
        throw Exception('Failed to get external storage directory');
      }
      var safeTitle = video.title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      var m4aPath = '${appDir.path}/$safeTitle.m4a';
      var tempMp3Path = '${appDir.path}/$safeTitle.mp3';
      var m4aFile = File(m4aPath);

      var streamSink = m4aFile.openWrite();
      int totalBytes = streamInfo.size.totalBytes;
      int receivedBytes = 0;

      await for (var chunk in stream) {
        receivedBytes += chunk.length;
        setState(() {
          _downloadProgress = receivedBytes / totalBytes;
        });
        streamSink.add(chunk);
      }
      await streamSink.flush();
      await streamSink.close();

      if (!await m4aFile.exists() || (await m4aFile.length()) == 0) {
        throw Exception('Download failed: .m4a not created or empty');
      }

      setState(() {
        _status = 'Uploading to CloudConvert...';
        _downloadProgress = null;
      });

      var jobResponse = await http.post(
        Uri.parse('https://api.cloudconvert.com/v2/jobs'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'tasks': {
            'import-my-file': {
              'operation': 'import/upload',
            },
            'convert-my-file': {
              'operation': 'convert',
              'input': ['import-my-file'],
              'input_format': 'm4a',
              'output_format': 'mp3',
              'audio_bitrate': int.parse(_selectedQuality.replaceAll('K', '')),
            },
            'export-my-file': {
              'operation': 'export/url',
              'input': ['convert-my-file'],
            },
          },
        }),
      );

      print('Job Response Status: ${jobResponse.statusCode}');
      print('Job Response Body: ${jobResponse.body}');

      if (jobResponse.statusCode != 201) {
        throw Exception('Failed to create job: ${jobResponse.body}');
      }

      var jobData = jsonDecode(jobResponse.body);
      if (jobData['data'] == null) {
        throw Exception('Job data is null: ${jobResponse.body}');
      }
      var jobId = jobData['data']['id'] as String?;

      var uploadTask = jobData['data']['tasks']?.firstWhere(
            (t) => t['name'] == 'import-my-file',
            orElse: () => null,
          );
      if (uploadTask == null) {
        throw Exception('Upload task not found: ${jobResponse.body}');
      }
      var uploadUrl = uploadTask['result']?['form']?['url'] as String?;
      var formData = uploadTask['result']?['form']?['parameters'] as Map?;
      if (uploadUrl == null || formData == null) {
        throw Exception('Upload URL or form data is null: $uploadTask');
      }

      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      formData.forEach((key, value) => request.fields[key] = value.toString());
      request.files.add(await http.MultipartFile.fromPath('file', m4aPath));
      var uploadResponse = await request.send();
      var uploadResponseBody = await uploadResponse.stream.bytesToString();

      print('Upload Response Status: ${uploadResponse.statusCode}');
      print('Upload Response Body: $uploadResponseBody');

      if (uploadResponse.statusCode != 201) {
        throw Exception(
            'Upload failed: ${uploadResponse.statusCode} - $uploadResponseBody');
      }

      setState(() {
        _status = 'Converting...';
      });

      String? downloadUrl;
      int attempts = 0;
      const maxAttempts = 30;
      while (downloadUrl == null && attempts < maxAttempts) {
        await Future.delayed(const Duration(seconds: 2));
        var statusResponse = await http.get(
          Uri.parse('https://api.cloudconvert.com/v2/jobs/$jobId'),
          headers: {'Authorization': 'Bearer $_apiKey'},
        );
        var statusData = jsonDecode(statusResponse.body);
        var exportTask = statusData['data']?['tasks']?.firstWhere(
              (t) => t['name'] == 'export-my-file',
              orElse: () => null,
            );
        if (statusData['data']?['status'] == 'finished' && exportTask != null) {
          downloadUrl = exportTask['result']?['files']?[0]?['url'] as String?;
        } else if (statusData['data']?['status'] == 'error') {
          throw Exception(
              'Conversion failed: ${statusData['data']['tasks']?[0]?['message'] ?? 'Unknown error'}');
        }
        attempts++;
      }

      if (downloadUrl == null) {
        throw Exception('Conversion timed out after ${maxAttempts * 2} seconds');
      }

      setState(() {
        _status = 'Downloading MP3...';
      });
      var mp3Response = await http.get(Uri.parse(downloadUrl));
      var tempMp3File = File(tempMp3Path);
      await tempMp3File.writeAsBytes(mp3Response.bodyBytes);

      var publicDownloadsDir = Directory('/storage/emulated/0/Download');
      var finalMp3Path = '${publicDownloadsDir.path}/$safeTitle.mp3';
      var finalMp3File = File(finalMp3Path);

      if (!await publicDownloadsDir.exists()) {
        await publicDownloadsDir.create(recursive: true);
      }
      await tempMp3File.copy(finalMp3Path);
      await tempMp3File.delete();
      await m4aFile.delete();

      await MediaScanner.loadMedia(path: finalMp3Path);

      setState(() {
        _status = 'Download Completed! Saved as $finalMp3Path';
      });
    } catch (e) {
      setState(() {
        _status = 'Failed: $e';
        _downloadProgress = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.black, // Black background
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40), // Space from top
                    ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.grey,
                            Colors.white70,
                          ],
                        ).createShader(bounds);
                      },
                      child: const Text(
                        'YTMp3',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Base color (will be overridden by gradient)
                          shadows: [
                            Shadow(
                              color: Colors.white54,
                              blurRadius: 20,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[900], // Dark grey card background
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _urlController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Enter YouTube URL',
                              labelStyle: TextStyle(color: Colors.grey[400]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[700]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[700]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.grey),
                              ),
                              filled: true,
                              fillColor: Colors.grey[800],
                              prefixIcon: Icon(Icons.link, color: Colors.grey[400]),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Audio Quality: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.grey[400],
                                ),
                              ),
                              DropdownButton<String>(
                                value: _selectedQuality,
                                items: ['64K', '128K', '192K', '256K', '320K']
                                    .map((String quality) {
                                  return DropdownMenuItem<String>(
                                    value: quality,
                                    child: Text(
                                      quality,
                                      style: TextStyle(color: Colors.grey[300]),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedQuality = newValue!;
                                  });
                                },
                                style: TextStyle(
                                  color: Colors.grey[300],
                                  fontSize: 16,
                                ),
                                dropdownColor: Colors.grey[800],
                                underline: Container(
                                  height: 2,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _downloadAndConvertAudio,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 5,
                            ),
                            child: const Text(
                              'Download',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Text(
                            _status,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _status.contains('Failed')
                                  ? Colors.red
                                  : _status.contains('Completed')
                                      ? Colors.green
                                      : Colors.grey[400],
                            ),
                            textAlign: TextAlign.center,
                            softWrap: true,
                          ),
                          const SizedBox(height: 20),
                          if (_downloadProgress != null) ...[
                            SizedBox(
                              width: 200,
                              child: LinearProgressIndicator(
                                value: _downloadProgress,
                                minHeight: 8,
                                backgroundColor: Colors.grey[700],
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.grey[500]!),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Progress: ${(_downloadProgress! * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}