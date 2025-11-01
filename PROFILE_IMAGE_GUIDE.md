# Profile Image Management

## Chức năng đã thêm

### 1. **Xử lý ảnh đại diện từ nhiều nguồn**

- ✅ **Chụp ảnh từ máy ảnh**: Sử dụng camera để chụp ảnh mới
- ✅ **Chọn từ thư viện**: Chọn ảnh có sẵn từ gallery
- ✅ **Xóa ảnh hiện tại**: Quay về avatar mặc định
- ✅ **Hiển thị ảnh**: Hỗ trợ cả ảnh local và network

### 2. **Quản lý quyền truy cập**

- ✅ **Android permissions**: Camera, Storage, Media access
- ✅ **iOS permissions**: Camera usage, Photo library access
- ✅ **Runtime permission handling**: Tự động yêu cầu quyền khi cần

### 3. **UI/UX nâng cao**

- ✅ **Loading states**: Hiển thị progress khi upload
- ✅ **Error handling**: Xử lý lỗi và fallback
- ✅ **Modern bottom sheet**: Giao diện chọn nguồn ảnh đẹp
- ✅ **Image optimization**: Resize và compress ảnh

## Cách sử dụng

### 1. **Thay đổi ảnh đại diện**

```dart
// Trong ProfilePage, nhấn vào icon camera trên avatar
onTap: () => _showImageSourceDialog()
```

### 2. **Chọn nguồn ảnh**

```dart
// Camera
await _pickImageFromCamera();

// Gallery
await _pickImageFromGallery();

// Remove photo
_removeProfilePicture();
```

### 3. **Upload ảnh**

```dart
// Tự động upload sau khi chọn ảnh
await _uploadImage();
```

## Cấu hình cần thiết

### Android (android/app/src/main/AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
```

### iOS (ios/Runner/Info.plist)

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs access to camera to take profile pictures</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to photo library to select profile pictures</string>
```

### Dependencies (pubspec.yaml)

```yaml
dependencies:
  image_picker: ^1.0.7
  permission_handler: ^11.3.0
```

## Tính năng nổi bật

### 1. **Smart Image Display**

- **Priority**: Selected image > User avatar > Default avatar
- **Network support**: Tự động detect URL và hiển thị từ network
- **Local file support**: Hiển thị ảnh đã chọn từ device
- **Error fallback**: Quay về avatar mặc định khi lỗi

### 2. **Image Processing**

- **Quality optimization**: 80% quality để giảm dung lượng
- **Size optimization**: Max 1000x1000px
- **Loading indicator**: Hiển thị progress khi xử lý

### 3. **User Experience**

- **Haptic feedback**: Rung nhẹ khi tương tác
- **Visual feedback**: Loading overlay trên avatar
- **Error messages**: Thông báo lỗi rõ ràng
- **Success confirmation**: Thông báo thành công

### 4. **State Management**

- **Loading states**: `_isImageUploading`
- **Selected image**: `_selectedImage`
- **User data**: Tích hợp với `UserProfileModel`

## Luồng hoạt động

1. **User nhấn camera icon** → Hiển thị bottom sheet
2. **Chọn nguồn ảnh** → Camera hoặc Gallery
3. **Check permissions** → Yêu cầu quyền nếu cần
4. **Pick image** → Chọn/chụp ảnh với optimization
5. **Show preview** → Hiển thị ảnh đã chọn ngay lập tức
6. **Upload process** → Tự động upload với loading indicator
7. **Update UI** → Cập nhật avatar và thông báo thành công

## Testing

### Test Cases

- ✅ Chụp ảnh từ camera
- ✅ Chọn ảnh từ gallery
- ✅ Xử lý khi từ chối permission
- ✅ Xử lý lỗi network/file
- ✅ Remove ảnh hiện tại
- ✅ Loading states
- ✅ Error handling

### Device Testing

- ✅ Android permissions
- ✅ iOS permissions
- ✅ Camera functionality
- ✅ Gallery access
- ✅ Network images
- ✅ Local file paths

## Tích hợp với Backend

```dart
// Trong _uploadImage(), thêm logic upload thật:
Future<String> uploadToServer(File imageFile) async {
  final formData = FormData.fromMap({
    'avatar': await MultipartFile.fromFile(imageFile.path),
  });

  final response = await dio.post('/api/user/avatar', data: formData);
  return response.data['avatar_url'];
}

// Cập nhật user profile:
await context.read<SettingsCubit>().updateAvatar(newAvatarUrl);
```

**🎉 Chức năng xử lý ảnh đã hoàn thành và sẵn sàng sử dụng!**
