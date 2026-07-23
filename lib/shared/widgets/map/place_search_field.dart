import 'dart:async';
import 'package:flutter/material.dart';
import 'package:treasureflow/core/maps/domain/entities/suggestion.dart';
import 'package:treasureflow/core/maps/presentation/providers/map_provider.dart';

class PlaceSearchField extends StatefulWidget {
  final MapProvider provider;
  final Future<void> Function(String placeId) onSuggestionSelected;
  final ValueChanged<bool>? onFocusChanged;

  const PlaceSearchField({
    super.key,
    required this.provider,
    required this.onSuggestionSelected,
    this.onFocusChanged,
  });

  @override
  State<PlaceSearchField> createState() => _PlaceSearchFieldState();
}

class _PlaceSearchFieldState extends State<PlaceSearchField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<Suggestion> _suggestions = [];
  bool _loading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      widget.onFocusChanged?.call(_focusNode.hasFocus);
      if (!_focusNode.hasFocus) {
        setState(() => _suggestions = []);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 600), () async {
      setState(() => _loading = true);
      final results = await widget.provider.fetchSuggestions(value, 'es');
      if (mounted) {
        setState(() {
          _suggestions = results;
          _loading = false;
        });
      }
    });
  }

  void _onSelect(Suggestion suggestion) async {
    _focusNode.unfocus();
    _controller.clear();
    setState(() => _suggestions = []);
    await widget.onSuggestionSelected(suggestion.placeId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: colors.surface,                
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _focusNode.hasFocus
                  ? colors.primary                  
                  : colors.outline,                
            ),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: _onChanged,
            style: theme.textTheme.bodyMedium,     
            decoration: InputDecoration(
              hintText: 'Busca tu dirección ...',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withOpacity(0.4),
              ),
              prefixIcon: _loading
                  ? Padding(
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.primary,   
                        ),
                      ),
                    )
                  : Icon(
                      Icons.search,
                      color: colors.onSurface.withOpacity(0.5),
                    ),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: colors.onSurface.withOpacity(0.5),
                      ),
                      onPressed: () {
                        _controller.clear();
                        setState(() => _suggestions = []);
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),

        // ── Lista de sugerencias ───────────────────────────────────────
        if (_suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: colors.surface,                
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.outline.withOpacity(0.4)),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 220),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: _suggestions.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: colors.outline.withOpacity(0.3),
              ),
              itemBuilder: (context, index) {
                final s = _suggestions[index];
                return ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.location_on_outlined,
                    color: colors.primary,         
                    size: 20,
                  ),
                  title: Text(
                    s.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurface,     
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => _onSelect(s),
                );
              },
            ),
          ),
      ],
    );
  }
}