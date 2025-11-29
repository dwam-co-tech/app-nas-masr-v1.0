// widgets/filters/filter_options_modal.dart

import 'package:flutter/material.dart';
import 'package:nas_masr_app/core/data/models/city.dart';
import 'package:nas_masr_app/core/data/models/governorate.dart';
import 'package:nas_masr_app/core/data/models/make.dart';
import 'package:nas_masr_app/core/data/models/car_model.dart';

class FilterOptionsModal extends StatefulWidget {
  final String title;
  final List<dynamic> options;
  final Function(dynamic selectedValue) onSelected;
  final bool requireApply;
  final bool showAllOption;

  const FilterOptionsModal({
    super.key,
    required this.title,
    required this.options,
    required this.onSelected,
    this.requireApply = true,
    this.showAllOption = false,
  });

  @override
  State<FilterOptionsModal> createState() => _FilterOptionsModalState();
}

class _FilterOptionsModalState extends State<FilterOptionsModal> {
  final TextEditingController _searchController = TextEditingController();
  dynamic _selectedItem;

  List<dynamic> get _filteredOptions {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return widget.options;
    return widget.options.where((item) {
      final name = _displayName(item).toLowerCase();
      return name.contains(q);
    }).toList();
  }

  String _displayName(dynamic item) {
    if (item is Map) {
      return item['name']?.toString() ?? '—';
    } else if (item is Governorate) {
      return item.name;
    } else if (item is City) {
      return item.name;
    } else if (item is Make) {
      return item.name;
    } else if (item is CarModel) {
      return item.name;
    } else if (item is String || item is int) {
      return item.toString();
    }
    return item.runtimeType.toString();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onSelected('__RESET__');
                        },
                        child: const Text('إعادة تعيين'),
                      ),
                      
                      Expanded(
                        child: Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                     
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'بحث',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 1.2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 1.6,
                        ),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 12),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                if (widget.showAllOption)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 6.0),
                    child: ListTile(
                      leading: const Icon(Icons.clear_all),
                      title: const Text('الكل'),
                      subtitle: const Text('عرض جميع الإعلانات'),
                      onTap: () {
                        Navigator.pop(context);
                        widget.onSelected('__ALL__');
                      },
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredOptions.length,
                    itemBuilder: (context, index) {
                      final item = _filteredOptions[index];
                      final name = _displayName(item);
                      return ListTile(
                        leading: Radio<dynamic>(
                          value: item,
                          groupValue: _selectedItem,
                          onChanged: (v) {
                            setState(() => _selectedItem = v);
                          },
                        ),
                        title: Text(name),
                        onTap: () {
                          if (widget.requireApply) {
                            setState(() => _selectedItem = item);
                          } else {
                            Navigator.pop(context);
                            widget.onSelected(item);
                          }
                        },
                      );
                    },
                  ),
                ),
                if (widget.requireApply)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selectedItem == null
                            ? null
                            : () {
                                Navigator.pop(context);
                                widget.onSelected(_selectedItem);
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                        child: const Text('تأكيد'),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ));
  }
}
