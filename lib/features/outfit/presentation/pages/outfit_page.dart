import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitsy/features/outfit/presentation/bloc/outfit_bloc.dart';
import 'package:fitsy/features/outfit/presentation/bloc/outfit_event.dart';
import 'package:fitsy/features/outfit/presentation/bloc/outfit_state.dart';
import 'package:fitsy/features/outfit/presentation/widgets/outfit_card.dart';

class OutfitPage extends StatelessWidget {
  const OutfitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 코디'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<OutfitBloc>().add(
                const LoadRecommendations(userId: 'temp-user'),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<OutfitBloc, OutfitState>(
        builder: (context, state) {
          if (state is OutfitLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is OutfitError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<OutfitBloc>().add(
                      const LoadRecommendations(userId: 'temp-user'),
                    ),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }
          if (state is OutfitLoaded) {
            if (state.outfits.isEmpty) {
              return const Center(child: Text('옷을 먼저 등록해주세요'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.outfits.length,
              itemBuilder: (context, index) =>
                  OutfitCard(outfit: state.outfits[index]),
            );
          }
          return Center(
            child: ElevatedButton.icon(
              onPressed: () => context.read<OutfitBloc>().add(
                const LoadRecommendations(userId: 'temp-user'),
              ),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('AI 코디 추천 받기'),
            ),
          );
        },
      ),
    );
  }
}
