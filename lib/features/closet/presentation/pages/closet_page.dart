import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fitsy/features/closet/presentation/bloc/closet_bloc.dart';
import 'package:fitsy/features/closet/presentation/bloc/closet_event.dart';
import 'package:fitsy/features/closet/presentation/bloc/closet_state.dart';
import 'package:fitsy/features/closet/presentation/widgets/cloth_grid_item.dart';

class ClosetPage extends StatelessWidget {
  const ClosetPage({super.key});

  static const categories = ['전체', '상의', '하의', '외투', '신발', '악세서리'];

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source, imageQuality: 85);
    if (image != null && context.mounted) {
      context.read<ClosetBloc>().add(
        AddClothEvent(userId: 'temp-user', imagePath: image.path),
      );
    }
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('카메라로 촬영'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('갤러리에서 선택'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(context, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ClosetBloc, ClosetState>(
      listener: (context, state) {
        if (state is ClothAdded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('옷이 추가되었습니다')),
          );
          context.read<ClosetBloc>().add(
            const LoadClothes(userId: 'temp-user'),
          );
        } else if (state is ClosetError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('내 옷장')),
        body: BlocBuilder<ClosetBloc, ClosetState>(
          builder: (context, state) {
            if (state is ClosetLoading || state is ClothAdding) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ClosetError) {
              return Center(child: Text(state.message));
            }
            if (state is ClosetLoaded) {
              return Column(
                children: [
                  SizedBox(
                    height: 48,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final selected =
                            (state.selectedCategory == null && cat == '전체') ||
                            state.selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(cat),
                            selected: selected,
                            onSelected: (_) {
                              context.read<ClosetBloc>().add(LoadClothes(
                                userId: 'temp-user',
                                category: cat == '전체' ? null : cat,
                              ));
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: state.clothes.isEmpty
                        ? const Center(
                            child: Text(
                              '옷장이 비어있습니다\n옷을 추가해보세요',
                              textAlign: TextAlign.center,
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: state.clothes.length,
                            itemBuilder: (context, index) =>
                                ClothGridItem(cloth: state.clothes[index]),
                          ),
                  ),
                ],
              );
            }
            return const Center(child: Text('옷장을 로드하세요'));
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showImageSourceDialog(context),
          child: const Icon(Icons.add_a_photo),
        ),
      ),
    );
  }
}
