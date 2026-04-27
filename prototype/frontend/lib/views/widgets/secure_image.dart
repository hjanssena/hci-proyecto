import 'dart:typed_data';
import 'package:bebeia_front/viewmodels/media_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SecureImage extends StatefulWidget {
  final String url;
  final BoxFit fit;

  const SecureImage({Key? key, required this.url, this.fit = BoxFit.contain})
    : super(key: key);

  @override
  State<SecureImage> createState() => _SecureImageState();
}

class _SecureImageState extends State<SecureImage> {
  late Future<Uint8List> _imageFuture;

  @override
  void initState() {
    super.initState();
    _fetchImage();
  }

  // If the parent widget passes a completely new URL, we must fetch the new one!
  @override
  void didUpdateWidget(covariant SecureImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _fetchImage();
    }
  }

  void _fetchImage() {
    // We grab the repo and assign the future to our stable state variable
    final mediaRepo = context.read<MediaViewModel>();
    _imageFuture = mediaRepo.getSecureImage(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _imageFuture, // Use the stable future, NOT a direct method call
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.broken_image, color: Colors.grey, size: 48),
                const SizedBox(height: 8),
                Text(
                  'Error de autenticación',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          );
        }

        return Image.memory(snapshot.data!, fit: widget.fit);
      },
    );
  }
}
