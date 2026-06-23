import 'package:flutter/material.dart';
import 'package:treasureflow/features/auth/local/presentation/widgets/location_detail_card_widget.dart';

class Step3LocationData extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step3LocationData({
    super.key, 
    required this.onNext, 
    required this.onBack
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
         
          Container(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
            width: double.infinity,
            height: double.infinity,
            child: const Center(
              child: Icon(Icons.map, size: 64, color: Colors.grey),
            ),
          ),
          
         
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: theme.colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    icon: Icon(Icons.search, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                    hintText: "Busca tu dirección...",
                    hintStyle: theme.textTheme.bodySmall,
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
          
          Positioned(
            bottom: 240,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {},
              backgroundColor: theme.colorScheme.surface,
              foregroundColor: theme.colorScheme.onSurface,
              child: const Icon(Icons.my_location),
            ),
          ),
          
         
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: LocationDetailCard(
              onNext: onNext,
              onBack: onBack,
              onEditAddress: () {
               
              },
            ),
          ),
        ],
      ),
    );
  }
}