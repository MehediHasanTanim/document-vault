import 'package:flutter/material.dart';

class PhysicalLocationListItem {
  const PhysicalLocationListItem({
    required this.id,
    required this.name,
    required this.documentCount,
    this.archived = false,
  });
  final String id;
  final String name;
  final int documentCount;
  final bool archived;
}

/// Physical-location names are passed in only after unlock and are never
/// rendered by locked routes or notification surfaces.
class PhysicalLocationsScreen extends StatelessWidget {
  const PhysicalLocationsScreen({
    required this.locations,
    required this.onAdd,
    required this.onEdit,
    required this.onArchive,
    super.key,
  });
  final List<PhysicalLocationListItem> locations;
  final VoidCallback onAdd;
  final ValueChanged<PhysicalLocationListItem> onEdit;
  final ValueChanged<PhysicalLocationListItem> onArchive;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Physical locations / আসল নথির স্থান')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: onAdd,
      icon: const Icon(Icons.add),
      label: const Text('Add / যোগ করুন'),
    ),
    body: locations.isEmpty
        ? const Center(
            child: Text(
              'Add where originals are kept.\nআসল নথি কোথায় রাখা আছে যোগ করুন।',
              textAlign: TextAlign.center,
            ),
          )
        : ListView.builder(
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final location = locations[index];
              return ListTile(
                leading: const Icon(Icons.inventory_2_outlined),
                title: Text(location.name),
                subtitle: Text(
                  '${location.documentCount} linked document${location.documentCount == 1 ? '' : 's'}',
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (action) =>
                      action == 'edit' ? onEdit(location) : onArchive(location),
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit / সম্পাদনা'),
                    ),
                    PopupMenuItem(
                      value: 'archive',
                      child: Text('Archive / আর্কাইভ'),
                    ),
                  ],
                ),
              );
            },
          ),
  );
}
