import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:uuid/uuid.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/utils/network_utilities.dart';

class ImageCarousel extends StatefulWidget {
  final bool isUpdate;
  final List? images;
  final String thumbnail;
  final String thumbnailKey;

  const ImageCarousel({
    super.key,
    this.isUpdate = false,
    this.images,
    required this.thumbnail,
    required this.thumbnailKey,
  });

  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  // Core state
  final Uuid _uuid = Uuid();
  bool loading = false;

  // Image state
  Map<String, Uint8List> imagesBytes = {};
  Map<String, String> filesPath = {};
  Map<String, PlatformFile> platformFiles = {};

  // Images for display
  List allImages = [];
  List deletedImages = [];
  String thumbnail = '';
  String thumbnailKey = '';
  PlatformFile? thumbnailFile;

  @override
  void initState() {
    super.initState();
    _initializeImages();
  }

  // Initialize images from props and temp storage
  void _initializeImages() {
    if (kDebugMode) {
      print("Initializing with images: ${widget.images?.length ?? 0}");
      print("Thumbnail: ${widget.thumbnail}");
    }

    setState(() {
      // Initialize from widget props
      thumbnail = widget.thumbnail;
      thumbnailKey = widget.thumbnailKey;

      if (widget.images != null && widget.images!.isNotEmpty) {
        allImages = [...widget.images!];
      }
    });

    // Load any temporary images from Hive
    _loadTempImages();
  }

  // Load temporary images from Hive
  void _loadTempImages() {
    final Box imageBox = Hive.box('images');
    final List tempImagesList = imageBox.get('tempImages', defaultValue: []);
    final Map? tempThumbnail = imageBox.get('tempThumbnail');

    if (tempImagesList.isNotEmpty) {
      if (kDebugMode) {
        print('Loading ${tempImagesList.length} temporary images');
      }

      setState(() {
        for (var tempImage in tempImagesList) {
          if (tempImage.containsKey('path') && tempImage.containsKey('name')) {
            final String tempImageId = tempImage['id'];
            final String tempImagePath = tempImage['path'];

            // Check if this temp image is already in allImages
            bool alreadyExists = false;
            for (var existingImage in allImages) {
              if (existingImage is Map<String, dynamic> &&
                  existingImage['imageKey'] == tempImageId) {
                alreadyExists = true;
                break;
              }
            }

            // Only add if not already present
            if (!alreadyExists) {
              allImages.add({
                'imageLink': tempImagePath,
                'imageKey': tempImageId,
                'isTemp': true,
              });

              // Store path for reference
              filesPath[tempImageId] = tempImagePath;
            }
          }
        }
      });
    }

    // Load temporary thumbnail if exists
    if (tempThumbnail != null &&
        tempThumbnail.containsKey('path') &&
        tempThumbnail.containsKey('name')) {
      if (thumbnail.isEmpty) {
        // Only use temp if no real thumbnail exists
        setState(() {
          thumbnail = tempThumbnail['path'];
          thumbnailKey = 'temp_${tempThumbnail['id']}';
        });
      }
    }
  }

  // Pick an image from device
  Future<void> _pickImage({bool isForThumbnail = false}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: !isForThumbnail,
      );

      if (result == null || result.files.isEmpty) return;

      setState(() => loading = true);

      if (isForThumbnail) {
        await _handleThumbnailSelection(result.files.first);
      } else {
        await _handleMultipleImageSelection(result.files);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image: $e');
      }
      _showErrorSnackBar('Failed to select image: ${e.toString()}');
    } finally {
      setState(() => loading = false);
    }
  }

  // Handle thumbnail selection
  Future<void> _handleThumbnailSelection(PlatformFile file) async {
    try {
      // If replacing existing thumbnail, mark it for deletion
      if (thumbnail.isNotEmpty &&
          thumbnail.contains('http') &&
          !thumbnailKey.startsWith('temp_')) {
        // Add to deleted images for server handling
        deletedImages.add({
          'imageLink': thumbnail,
          'imageKey': thumbnailKey,
        });
      }

      // Store temporary thumbnail
      final tempThumbnail = await _storeTempThumbnail(file);

      setState(() {
        thumbnailFile = file;
        thumbnail = tempThumbnail['path'];
        thumbnailKey = 'temp_${tempThumbnail['id']}';
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error handling thumbnail selection: $e');
      }
      _showErrorSnackBar('Failed to process thumbnail: ${e.toString()}');
    }
  }

  // Store temporary thumbnail
  Future<Map<String, dynamic>> _storeTempThumbnail(PlatformFile file) async {
    // Generate a unique ID
    final String tempId = _uuid.v4();

    // Get a URL for preview
    String? localUrl = _getLocalImageUrl(file);
    if (localUrl == null) {
      throw Exception('Failed to create preview URL');
    }

    // Create temporary thumbnail data
    final Map<String, dynamic> tempThumbnail = {
      'id': tempId,
      'name': file.name,
      'path': localUrl,
      'size': file.size,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    // Store in Hive
    final Box imageBox = Hive.box('images');
    await imageBox.put('tempThumbnail', tempThumbnail);

    return tempThumbnail;
  }

  // Handle multiple image selection
  Future<void> _handleMultipleImageSelection(List<PlatformFile> files) async {
    try {
      final Box imageBox = Hive.box('images');
      List tempImagesList = imageBox.get('tempImages', defaultValue: []);

      for (final file in files) {
        final String tempId = _uuid.v4();
        String? localUrl = _getLocalImageUrl(file);

        if (localUrl == null) {
          if (kDebugMode) {
            print('Failed to create preview for image: ${file.name}');
          }
          continue;
        }

        // Create temporary image data
        final Map<String, dynamic> tempImage = {
          'id': tempId,
          'name': file.name,
          'path': localUrl,
          'size': file.size,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };

        // Add to temporary images list
        tempImagesList.add(tempImage);

        // Update UI and references
        setState(() {
          allImages.add({
            'imageLink': localUrl,
            'imageKey': tempId,
            'isTemp': true,
          });

          filesPath[tempId] = localUrl;
          platformFiles[tempId] = file;
        });
      }

      // Save to Hive
      await imageBox.put('tempImages', tempImagesList);
    } catch (e) {
      if (kDebugMode) {
        print('Error handling multiple image selection: $e');
      }
      _showErrorSnackBar('Failed to process images: ${e.toString()}');
    }
  }

  // Create URL for local image display
  String? _getLocalImageUrl(PlatformFile file) {
    // For mobile, use the file path
    if (file.path != null) {
      return file.path;
    }
    return null;
  }

  // Get MIME type from file name
  String _getMimeType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'bmp':
        return 'image/bmp';
      default:
        return 'image/jpeg'; // Default
    }
  }

  // Delete image (either thumbnail or regular image)
  Future<void> _deleteImage({bool isThumbnail = false, int? index}) async {
    setState(() => loading = true);

    try {
      if (isThumbnail) {
        await _deleteThumbnail();
      } else if (index != null && index < allImages.length) {
        await _deleteRegularImage(index);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to delete image: ${e.toString()}');
    } finally {
      setState(() => loading = false);
    }
  }

  // Delete thumbnail
  Future<void> _deleteThumbnail() async {
    // If it's a remote thumbnail, add to deletedImages list
    if (thumbnail.contains('http') && !thumbnailKey.startsWith('temp_')) {
      deletedImages.add({
        'imageLink': thumbnail,
        'imageKey': thumbnailKey,
      });
    }

    // Clear temporary thumbnail if it exists
    final Box imageBox = Hive.box('images');
    await imageBox.delete('tempThumbnail');

    setState(() {
      thumbnail = '';
      thumbnailKey = '';
      thumbnailFile = null;
    });
  }

  // Delete a regular image
  Future<void> _deleteRegularImage(int index) async {
    final image = allImages[index];
    bool isTemp = false;

    if (image is Map<String, dynamic>) {
      isTemp = image['isTemp'] == true;

      if (!isTemp && image.containsKey('imageKey')) {
        // This is a remote image, add to deletedImages list
        deletedImages.add(Map<String, dynamic>.from(image));
      } else if (isTemp) {
        // This is a temporary image, remove from temp storage
        await _deleteTempImage(image['imageKey']);
      }
    }

    setState(() {
      allImages.removeAt(index);
    });
  }

  // Delete a temporary image
  Future<void> _deleteTempImage(String id) async {
    final Box imageBox = Hive.box('images');
    List tempImagesList = imageBox.get('tempImages', defaultValue: []);

    tempImagesList.removeWhere((img) => img['id'] == id);
    await imageBox.put('tempImages', tempImagesList);

    // Clean up references
    filesPath.remove(id);
    platformFiles.remove(id);
  }

  // Save all images - this is where we integrate with NetworkUtility
  Future<void> _saveImages() async {
    final Box imageBox = Hive.box('images');

    setState(() => loading = true);

    try {
      List<Map<String, dynamic>> productImages = [];
      Map<String, dynamic> thumbnailImage = {};

      // 1. Upload any new temporary images
      // Handle temporary thumbnail first
      if (thumbnailFile != null) {
        try {
          final imageUrlData = await NetworkUtility.uploadImageFromNative(
            file: thumbnailFile!,
            folder: 'product_images',
          );

          thumbnailImage = {
            'thumbnailLink': imageUrlData['url'],
            'thumbnailKey': imageUrlData['key'],
          };

          if (kDebugMode) {
            print('Uploaded thumbnail: ${imageUrlData['url']}');
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error uploading thumbnail: $e');
          }
          _showErrorSnackBar('Failed to upload thumbnail: ${e.toString()}');
        }
      } else if (thumbnail.isNotEmpty && !thumbnailKey.startsWith('temp_')) {
        // Keep existing non-temporary thumbnail
        thumbnailImage = {
          'thumbnailLink': thumbnail,
          'thumbnailKey': thumbnailKey,
        };
      }

      // 2. Upload temporary regular images
      for (int i = 0; i < allImages.length; i++) {
        final image = allImages[i];
        bool isTemp = false;

        if (image is Map<String, dynamic>) {
          isTemp = image['isTemp'] == true;

          if (isTemp) {
            // This is a temporary image, upload it
            final String tempId = image['imageKey'];
            if (platformFiles.containsKey(tempId)) {
              try {
                final uploadResult = await NetworkUtility.uploadImageFromNative(
                  file: platformFiles[tempId]!,
                  folder: 'product_images',
                );

                productImages.add({
                  'imageLink': uploadResult['url'],
                  'imageKey': uploadResult['key'],
                });

                if (kDebugMode) {
                  print('Uploaded image: ${uploadResult['url']}');
                }
              } catch (e) {
                if (kDebugMode) {
                  print('Error uploading image: $e');
                }
                // Continue with other images even if one fails
              }
            }
          } else {
            // This is an existing image, keep it
            productImages.add(Map<String, dynamic>.from(image));
          }
        }
      }

      // 3. Save to Hive for the parent screen to use
      await imageBox.put('productImages', productImages);
      await imageBox.put('thumbnailImage', thumbnailImage);
      await imageBox.put('deletedImages', deletedImages);

      // 4. Clean up temporary data
      await imageBox.delete('tempImages');
      await imageBox.delete('tempThumbnail');

      Navigator.pop(context);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving images: $e');
      }
      _showErrorSnackBar('Failed to save images: ${e.toString()}');
    } finally {
      setState(() => loading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: loading,
      progressIndicator: const CircularProgressIndicator(color: kMainColor),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Product Images', style: kAppBarTitleTextStyle),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(FontAwesomeIcons.chevronLeft),
            color: kSubMainColor,
            iconSize: 20.0,
          ),
        ),
        body: SafeArea(child: _buildBody()),
      ),
    );
  }

  // Main body widget
  Widget _buildBody() {
    return Container(
      padding: const EdgeInsets.all(15.0),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Content area (88% of screen)
          FractionallySizedBox(
            heightFactor: 0.88,
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                _buildThumbnailSection(),
                const SizedBox(height: 10.0),
                _buildImagesGridSection(),
              ],
            ),
          ),

          // Save button (12% of screen at bottom)
          FractionallySizedBox(
            heightFactor: 0.08,
            alignment: Alignment.bottomCenter,
            child: _buildSaveButton(),
          ),
        ],
      ),
    );
  }

  // Thumbnail section
  Widget _buildThumbnailSection() {
    return _buildImageContainer(
      height: MediaQuery.of(context).size.height * 0.3,
      width: double.infinity,
      onTap: () => _pickImage(isForThumbnail: true),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Thumbnail or placeholder
          (thumbnail.isNotEmpty || thumbnailFile != null)
              ? _buildImageDisplay(
                  image: thumbnail,
                  isTemp: thumbnailKey.startsWith('temp_'),
                  file: thumbnailFile,
                )
              : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, size: 40.0),
                      SizedBox(height: 10),
                      Text(
                        'Add Thumbnail Image',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

          // Delete button (only if thumbnail exists)
          if (thumbnail.isNotEmpty || thumbnailFile != null)
            Positioned(
              top: 8,
              right: 8,
              child: _buildDeleteButton(
                onTap: () => _deleteImage(isThumbnail: true),
              ),
            ),

          // Temporary indicator
          if (thumbnail.isNotEmpty && thumbnailKey.startsWith('temp_'))
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'New',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Grid of product images
  Widget _buildImagesGridSection() {
    return Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 10.0,
          childAspectRatio: 1.0,
        ),
        itemCount: allImages.length + 1, // +1 for the add button
        itemBuilder: (context, index) {
          // The first item is always the "add more" button
          if (index == 0) {
            return _buildImageContainer(
              onTap: () => _pickImage(isForThumbnail: false),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 25.0),
                    SizedBox(height: 5),
                    Text("Add Images", textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }

          // Display existing images
          final imageIndex = index - 1;
          final image = allImages[imageIndex];
          bool isTemp = false;
          String imageUrl = '';

          if (image is Map<String, dynamic>) {
            isTemp = image['isTemp'] == true;
            imageUrl = image['imageLink'] ?? '';
          } else if (image is String) {
            imageUrl = image;
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              // Image
              _buildImageContainer(
                onTap: null,
                child: _buildImageDisplay(
                  image: imageUrl,
                  isTemp: isTemp,
                ),
              ),

              // Delete button
              Positioned(
                top: 8,
                right: 8,
                child: _buildDeleteButton(
                  onTap: () => _deleteImage(index: imageIndex),
                ),
              ),

              // Temporary indicator
              if (isTemp)
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'New',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // Display image based on source (remote, local, temporary)
  Widget _buildImageDisplay({
    required String image,
    bool isTemp = false,
    PlatformFile? file,
  }) {
    if (image.isEmpty) {
      return const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 40,
          color: Colors.grey,
        ),
      );
    }

    if (isTemp) {
      // For temporary images, handle differently based on platform
      if (kIsWeb) {
        // For web, image might be a data URL
        if (image.startsWith('data:')) {
          return Image.network(
            image,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _buildErrorPlaceholder(),
          );
        }
      } else {
        // For mobile, image is a file path
        return Image.file(
          File(image),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildErrorPlaceholder(),
        );
      }
    }

    // For remote images
    if (image.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: image,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildLoadingPlaceholder(),
        errorWidget: (context, url, error) => _buildErrorPlaceholder(),
      );
    }

    // Fallback
    return _buildErrorPlaceholder();
  }

  // Container for images with consistent styling
  Widget _buildImageContainer({
    required void Function()? onTap,
    required Widget child,
    double height = 100,
    double? width,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: kspareColor,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: child,
        ),
      ),
    );
  }

  // Reusable delete button
  Widget _buildDeleteButton({required void Function()? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 30.0,
        width: 30.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100.0),
          color: Colors.white.withOpacity(0.8),
        ),
        child: const Icon(
          Icons.cancel,
          color: Colors.red,
          size: 20.0,
        ),
      ),
    );
  }

  // Loading placeholder
  Widget _buildLoadingPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: kMainColor,
        ),
      ),
    );
  }

  // Error placeholder
  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(
          Icons.broken_image_rounded,
          size: 40,
          color: Colors.grey,
        ),
      ),
    );
  }

  // Save button
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveImages,
        style: ElevatedButton.styleFrom(
          backgroundColor: kMainColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        child: const Text(
          'Save Images',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
