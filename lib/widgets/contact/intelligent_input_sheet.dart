import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class IntelligentInputSheet extends StatefulWidget {
  final TextEditingController aiInputController;
  final bool isLoading;
  final bool isListening;
  final VoidCallback onToggleListening;
  final Function(String) onProcessInput;

  const IntelligentInputSheet({
    super.key,
    required this.aiInputController,
    required this.isLoading,
    required this.isListening,
    required this.onToggleListening,
    required this.onProcessInput,
  });

  @override
  State<IntelligentInputSheet> createState() => _IntelligentInputSheetState();
}

class _IntelligentInputSheetState extends State<IntelligentInputSheet> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.isListening) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(IntelligentInputSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening && !oldWidget.isListening) {
      _animationController.repeat(reverse: true);
    } else if (!widget.isListening && oldWidget.isListening) {
      _animationController.stop();
      _animationController.reset();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 20,
        right: 20,
        top: 12,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          Text(
            l10n.intelligentInput,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          if (widget.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Column(
                  children: [
                    CircularProgressIndicator(strokeWidth: 3),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            )
          else ...[
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                TextField(
                  controller: widget.aiInputController,
                  maxLines: 5,
                  minLines: 3,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: l10n.aiInputHint,
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                if (widget.aiInputController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () => setState(() => widget.aiInputController.clear()),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 32),
            
            Column(
              children: [
                GestureDetector(
                  onTap: widget.onToggleListening,
                  child: ScaleTransition(
                    scale: widget.isListening ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isListening
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                        boxShadow: [
                          BoxShadow(
                            color: (widget.isListening
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.primary)
                                .withValues(alpha: 0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: Icon(
                        widget.isListening ? Icons.stop : Icons.mic,
                        size: 40,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.isListening ? l10n.listening : l10n.tapToSpeak,
                  style: TextStyle(
                    color: widget.isListening
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: widget.aiInputController.text.trim().isEmpty || widget.isListening
                  ? null
                  : () => widget.onProcessInput(widget.aiInputController.text.trim()),
              child: Text(
                l10n.recognize,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
