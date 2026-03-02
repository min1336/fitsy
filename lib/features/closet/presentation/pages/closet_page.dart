import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitsy/features/closet/presentation/bloc/closet_bloc.dart';
import 'package:fitsy/features/closet/presentation/bloc/closet_event.dart';
import 'package:fitsy/features/closet/presentation/bloc/closet_state.dart';
import 'package:fitsy/features/closet/presentation/widgets/cloth_grid_item.dart';

class ClosetPage extends StatelessWidget {
  const ClosetPage({super.key});

  static const categories = ['전체', '상의', '하의', '외투', '신발', '악세서리'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('내 옷장')),
      body: BlocBuilder<ClosetBloc, ClosetState>(
        builder: (context, state) {
          if (state is ClosetLoading) {
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
                              userId: 'temp-user', // TODO: 실제 사용자 ID
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
        onPressed: () {
          // TODO: 카메라/갤러리 선택 후 옷 추가
        },
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}
