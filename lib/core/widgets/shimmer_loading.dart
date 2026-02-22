import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_spacing.dart';
import 'app_widgets.dart';

/// Generic Shimmer Loading widget
class ShimmerLoading extends StatelessWidget {
  final Widget child;

  const ShimmerLoading({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: child,
    );
  }
}

/// Shimmer variant for a list of cards
class ShimmerCardList extends StatelessWidget {
  final int itemCount;
  final double cardHeight;

  const ShimmerCardList({
    super.key,
    this.itemCount = 5,
    this.cardHeight = 100,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: AppSpacing.screenPadding,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: ShimmerLoading(
            child: AppCard(
              child: Container(
                height: cardHeight,
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 150,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      width: 200,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      width: 100,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
