import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:viraeshop_admin/configs/functions.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/screens/image_carousel.dart';
import 'package:viraeshop_admin/utils/network_utilities.dart';

/// A helper class to streamline product operations in the application.
/// This class provides methods for handling product data, focusing on improved readability and maintainability.
class ProductHelper {
  // Hive box names
  static const String productsBox = 'productsBox';
  static const String productsKey = 'productsKey';
  static const String imagesBox = 'images';
  
  /// Initialize product data for editing
  /// This function loads product data into Hive storage, handling image duplication for UI display.
  /// The thumbnail is stored separately for UI purposes but will be included in allImages for server.
  static void initializeProductForEditing(Map<String, dynamic> productInfo) {
    if (productInfo.isEmpty) return;
    
    // Get the thumbnail info
    final String thumbnail = productInfo['thumbnail'] ?? '';
    final String thumbnailKey = productInfo['thumbnailKey'] ?? '';
    
    // Get all product images - use as-is from server (with thumbnail included)
    List<dynamic> allImages = List.from(productInfo['images'] ?? []);
    
    // Filter out thumbnail from display images to avoid duplication IN THE UI ONLY
    List<dynamic> displayImages = [];
    
    if (thumbnail.isNotEmpty && thumbnailKey.isNotEmpty) {
      displayImages = allImages.where((image) {
        if (image is Map<String, dynamic>) {
          return image['imageLink'] != thumbnail && 
                 image['imageKey'] != thumbnailKey;
        }
        return true;
      }).toList();
    } else {
      displayImages = allImages;
    }
    
    // Setup Hive boxes with processed data
    final Box imageBox = Hive.box(imagesBox);
    imageBox.put('productImages', displayImages);
    imageBox.put('thumbnailImage', {
      'thumbnailLink': thumbnail,
      'thumbnailKey': thumbnailKey,
    });
    
    // Initialize other product data as needed
    Hive.box('category').putAll({
      'name': productInfo['category'] ?? '',
      'categoryId': productInfo['categoryId'] ?? '',
    });
    
    Hive.box('subCategory').putAll({
      'name': productInfo['subCategory'] ?? '',
      'subCategoryId': productInfo['subCategoryId'] ?? '',
      'categoryId': productInfo['categoryId'] ?? '',
    });
    
    Hive.box('suppliers').putAll(productInfo['supplier'] ?? {});
    
    if (kDebugMode) {
      print('Initialized product for editing: ${productInfo['name']}');
      print('Display Images: ${displayImages.length}, Thumbnail: $thumbnail');
      print('Original allImages length (including thumbnail): ${allImages.length}');
    }
  }
  
  /// Navigate to image carousel for selecting/editing images
  static Future<void> navigateToImageCarousel(BuildContext context) async {
    // Get current image data
    final imageData = getProductImageData();
    
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageCarousel(
          isUpdate: imageData['thumbnail'].isNotEmpty,
          images: imageData['images'],
          thumbnail: imageData['thumbnail'],
          thumbnailKey: imageData['thumbnailKey'],
        ),
      ),
    );
  }
  
  /// Get current product image data from Hive
  static Map<String, dynamic> getProductImageData() {
    final Box imageBox = Hive.box(imagesBox);
    
    // Get images that have been saved in Hive
    final List productImages = imageBox.get('productImages', defaultValue: []);
    final Map thumbnailImage = imageBox.get('thumbnailImage', defaultValue: {});
    
    Map<String, dynamic> result = {
      'images': productImages,
      'thumbnail': thumbnailImage.isNotEmpty ? thumbnailImage['thumbnailLink'] : '',
      'thumbnailKey': thumbnailImage.isNotEmpty ? thumbnailImage['thumbnailKey'] : '',
      'hasThumbnail': thumbnailImage.isNotEmpty,
    };
    
    return result;
  }
  
  /// Check if there are any images (thumbnail or product images)
  static bool hasImages() {
    final Box imageBox = Hive.box(imagesBox);
    final List productImages = imageBox.get('productImages', defaultValue: []);
    final Map thumbnailImage = imageBox.get('thumbnailImage', defaultValue: {});
    
    return productImages.isNotEmpty || thumbnailImage.isNotEmpty;
  }
  
  /// Prepare product images for saving
  /// This includes uploading temporary images and ALWAYS includes thumbnail in allImages
  static Future<Map<String, dynamic>> prepareProductImagesForSaving() async {
    try {
      // Get existing images
      final Box imageBox = Hive.box(imagesBox);
      List productImages = imageBox.get('productImages', defaultValue: []);
      Map thumbnailImage = imageBox.get('thumbnailImage', defaultValue: {});
      List tempImages = imageBox.get('tempImages', defaultValue: []);
      Map? tempThumbnail = imageBox.get('tempThumbnail');
      List deletedImages = imageBox.get('deletedImages', defaultValue: []);
      
      // Lists to track our changes
      List<Map<String, dynamic>> finalImages = [];
      Map<String, dynamic> finalThumbnail = {};
      
      // 1. Process existing images first
      for (var image in productImages) {
        if (image is Map<String, dynamic>) {
          finalImages.add(Map<String, dynamic>.from(image));
        }
      }
      
      // 2. Use existing thumbnail if available
      if (thumbnailImage.isNotEmpty) {
        finalThumbnail = Map<String, dynamic>.from(thumbnailImage);
      }
      
      // 3. Upload temporary images if there are any
      if (tempImages.isNotEmpty) {
        final uploadedImages = await _uploadTempImages(tempImages);
        finalImages.addAll(uploadedImages);
      }
      
      // 4. Upload temporary thumbnail if exists
      if (tempThumbnail != null && tempThumbnail.isNotEmpty) {
        final uploadedThumbnail = await _uploadTempThumbnail(tempThumbnail);
        if (uploadedThumbnail.isNotEmpty) {
          finalThumbnail = uploadedThumbnail;
        }
      }
      
      // 5. Create allImages list (ALWAYS include thumbnail) for server
      List<Map<String, dynamic>> allImages = List.from(finalImages);
      
      // 6. ALWAYS add thumbnail to allImages if it exists, whether already included or not
      if (finalThumbnail.isNotEmpty) {
        final String thumbnailUrl = finalThumbnail['thumbnailLink'] ?? '';
        final String thumbnailKey = finalThumbnail['thumbnailKey'] ?? '';
        
        if (thumbnailUrl.isNotEmpty && thumbnailKey.isNotEmpty) {
          // Add thumbnail to allImages list
          allImages.add({
            'imageLink': thumbnailUrl,
            'imageKey': thumbnailKey,
          });
        }
      }
      
      // 7. Clear temporary images after processing
      await imageBox.delete('tempImages');
      await imageBox.delete('tempThumbnail');
      
      return {
        'allImages': allImages,  // Complete list for server (always includes thumbnail)
        'displayImages': finalImages,  // Images for UI display (without thumbnail duplication)
        'thumbnail': finalThumbnail.isNotEmpty ? finalThumbnail['thumbnailLink'] : '',
        'thumbnailKey': finalThumbnail.isNotEmpty ? finalThumbnail['thumbnailKey'] : '',
        'deletedImages': deletedImages,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error preparing product images: $e');
      }
      rethrow;
    }
  }
  
  /// Upload temporary images to server
  static Future<List<Map<String, dynamic>>> _uploadTempImages(List tempImages) async {
    List<Map<String, dynamic>> uploadedImages = [];
    
    for (final tempImage in tempImages) {
      try {
        // Create PlatformFile for upload
        final PlatformFile file = _createPlatformFileFromTempData(tempImage);
        
        // Upload to server
        final uploadResult = await NetworkUtility.uploadImageFromNative(
          file: file,
          folder: 'product_images',
        );
        
        // Add to results
        uploadedImages.add({
          'imageLink': uploadResult['url'],
          'imageKey': uploadResult['key'],
        });
      } catch (e) {
        if (kDebugMode) {
          print('Error uploading temp image: $e');
        }
        // Continue with other images even if one fails
      }
    }
    
    return uploadedImages;
  }
  
  /// Upload temporary thumbnail to server
  static Future<Map<String, dynamic>> _uploadTempThumbnail(Map tempThumbnail) async {
    try {
      // Create PlatformFile for upload
      final PlatformFile file = _createPlatformFileFromTempData(tempThumbnail);
      
      // Upload to server
      final uploadResult = await NetworkUtility.uploadImageFromNative(
        file: file,
        folder: 'product_images',
      );
      
      return {
        'thumbnailLink': uploadResult['url'],
        'thumbnailKey': uploadResult['key'],
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading temp thumbnail: $e');
      }
      return {};
    }
  }
  
  /// Create a PlatformFile from temporary image data
  static PlatformFile _createPlatformFileFromTempData(Map tempData) {
    final String tempImagePath = tempData['path'];
    final String tempImageName = tempData['name'];
    final int tempImageSize = tempData['size'] ?? 0;
    
    // Create PlatformFile for upload
    return PlatformFile(
      name: tempImageName,
      path: kIsWeb ? null : tempImagePath,
      size: tempImageSize,
      bytes: kIsWeb ? _extractDataUrlBytes(tempImagePath) : null,
    );
  }
  
  /// Extract bytes from a data URL (for web platform)
  static Uint8List? _extractDataUrlBytes(String dataUrl) {
    if (!dataUrl.startsWith('data:')) {
      return null;
    }
    
    try {
      final int commaIndex = dataUrl.indexOf(',');
      if (commaIndex == -1) return null;
      
      final String base64Data = dataUrl.substring(commaIndex + 1);
      return Uint8List.fromList(_base64Decode(base64Data));
    } catch (e) {
      if (kDebugMode) {
        print('Error extracting bytes from data URL: $e');
      }
      return null;
    }
  }
  
  /// Base64 decode helper
  static List<int> _base64Decode(String source) {
    String normalized = source.replaceAll('-', '+').replaceAll('_', '/');
    while (normalized.length % 4 != 0) {
      normalized += '=';
    }
    return base64.decode(normalized);
  }
  
  /// Clean up image data
  static Future<void> cleanupImageData() async {
    try {
      final Box imageBox = Hive.box(imagesBox);
      await imageBox.delete('productImages');
      await imageBox.delete('thumbnailImage');
      await imageBox.delete('deletedImages');
      await imageBox.delete('tempImages');
      await imageBox.delete('tempThumbnail');
      
      if (kDebugMode) {
        print('Image data cleaned up');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error cleaning up image data: $e');
      }
    }
  }
  
  /// Create or update a product in local storage
  static Future<void> saveProductToLocalStorage(Map<String, dynamic> product) async {
    try {
      final Box box = Hive.box(productsBox);
      List products = box.get(productsKey, defaultValue: []);
      
      // Check if product already exists
      bool productExists = false;
      int productIndex = -1;
      
      for (int i = 0; i < products.length; i++) {
        if (products[i]['productId'] == product['productId']) {
          productExists = true;
          productIndex = i;
          break;
        }
      }
      
      if (productExists && productIndex != -1) {
        // Update existing product
        products[productIndex] = product;
      } else {
        // Add new product
        products.add(product);
      }
      
      // Save to Hive
      await box.put(productsKey, products);
      
      if (kDebugMode) {
        print('Product saved to local storage: ${product['name']}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving product to local storage: $e');
      }
      rethrow;
    }
  }
  
  /// Delete a product from local storage
  static Future<bool> deleteProductFromLocalStorage(String productId) async {
    try {
      final Box box = Hive.box(productsBox);
      List products = box.get(productsKey, defaultValue: []);
      
      products.removeWhere((product) => product['productId'] == productId);
      
      await box.put(productsKey, products);
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting product from local storage: $e');
      }
      return false;
    }
  }
  
  /// Get a product by ID from local storage
  static Map<String, dynamic>? getProductById(String productId) {
    try {
      final Box box = Hive.box(productsBox);
      List products = box.get(productsKey, defaultValue: []);
      
      for (var product in products) {
        if (product['productId'] == productId) {
          return Map<String, dynamic>.from(product);
        }
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting product from local storage: $e');
      }
      return null;
    }
  }
  
  /// Collect all form data for a product
  static Map<String, dynamic> collectProductFormData({
    required String name,
    required String productCode,
    required String description,
    required String generalPrice,
    required String agentsPrice,
    required String architectPrice,
    required String costPrice,
    required String quantity,
    required String minimum,
    required bool isGeneralDiscount,
    required bool isAgentDiscount,
    required bool isArchitectDiscount,
    required String generalDiscount,
    required String agentsDiscount,
    required String architectDiscount,
    required bool isInfinity,
    required bool isNonInventory,
    required bool freeShipping,
    required bool comingSoon,
    required String sellBy,
  }) {
    // Get category data
    final categoryData = Hive.box('category').toMap();
    final subCategoryData = Hive.box('subCategory').toMap();
    final supplierData = Hive.box('suppliers').toMap();
    return {
      'supplierId': supplierData['supplierId'] ?? '',
      'name': name,
      'productCode': productCode,
      'description': description,
      'generalPrice': _parseNumOrZero(generalPrice),
      'agentsPrice': _parseNumOrZero(agentsPrice),
      'architectPrice': _parseNumOrZero(architectPrice),
      'costPrice': _parseNumOrZero(costPrice),
      'quantity': isInfinity ? 0 : _parseNumOrZero(quantity),
      'minimum': isInfinity ? 0 : _parseNumOrZero(minimum),
      'isGeneralDiscount': isGeneralDiscount,
      'isAgentDiscount': isAgentDiscount,
      'isArchitectDiscount': isArchitectDiscount,
      'generalDiscount': isGeneralDiscount ? _parseNumOrZero(generalDiscount) : 0,
      'agentsDiscount': isAgentDiscount ? _parseNumOrZero(agentsDiscount) : 0,
      'architectDiscount': isArchitectDiscount ? _parseNumOrZero(architectDiscount) : 0,
      'isInfinity': isInfinity,
      'isNonInventory': isNonInventory,
      'freeShipping': freeShipping,
      'comingSoon': comingSoon,
      'category': categoryData['name'] ?? '',
      'categoryId': categoryData['categoryId'] ?? '',
      'subCategory': subCategoryData['name'] ?? '',
      'subCategoryId': subCategoryData['subCategoryId'] ?? '',
      'sellBy': sellBy,
      'supplier': supplierData,
      'totalSales': 0,
    };
  }
  
  /// Parse a string to a number or return zero
  static num _parseNumOrZero(String value) {
    if (value.isEmpty) return 0;
    return num.tryParse(value) ?? 0;
  }
}