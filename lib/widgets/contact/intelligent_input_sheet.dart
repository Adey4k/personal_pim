import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _IntelligentInputSheetState extends State<IntelligentInputSheet>
    with SingleTickerProviderStateMixin {
  static const int _aiInputMaxLength = 256;

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
    widget.aiInputController.addListener(_handleAiInputChanged);
    _enforceAiInputLimit();

    if (widget.isListening) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(IntelligentInputSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.aiInputController != widget.aiInputController) {
      oldWidget.aiInputController.removeListener(_handleAiInputChanged);
      widget.aiInputController.addListener(_handleAiInputChanged);
      _enforceAiInputLimit();
    }

    if (widget.isListening && !oldWidget.isListening) {
      _animationController.repeat(reverse: true);
    } else if (!widget.isListening && oldWidget.isListening) {
      _animationController.stop();
      _animationController.reset();
    }
  }

  void _handleAiInputChanged() {
    if (_enforceAiInputLimit() || !mounted) return;
    setState(() {});
  }

  bool _enforceAiInputLimit() {
    final text = widget.aiInputController.text;
    if (text.runes.length <= _aiInputMaxLength) return false;

    final limitedText = String.fromCharCodes(
      text.runes.take(_aiInputMaxLength),
    );
    widget.aiInputController.value = TextEditingValue(
      text: limitedText,
      selection: TextSelection.collapsed(offset: limitedText.length),
    );
    return true;
  }

  @override
  void dispose() {
    widget.aiInputController.removeListener(_handleAiInputChanged);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final aiInputText = widget.aiInputController.text;
    final hasAiInputText = aiInputText.trim().isNotEmpty;
    final canRecognize = hasAiInputText && !widget.isListening;

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
                  maxLength: _aiInputMaxLength,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(_aiInputMaxLength),
                  ],
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: l10n.aiInputHint,
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                if (aiInputText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () =>
                          setState(() => widget.aiInputController.clear()),
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
                    scale: widget.isListening
                        ? _pulseAnimation
                        : const AlwaysStoppedAnimation(1.0),
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
                            color:
                                (widget.isListening
                                        ? theme.colorScheme.error
                                        : theme.colorScheme.primary)
                                    .withValues(alpha: 0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
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

            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    disabledBackgroundColor:
                        theme.colorScheme.surfaceContainerHighest,
                    disabledForegroundColor: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.6),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: canRecognize
                      ? () => widget.onProcessInput(aiInputText.trim())
                      : null,
                  child: Text(
                    l10n.recognize,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (!canRecognize)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      widget.isListening
                          ? l10n.stopRecordingToRecognize
                          : l10n.enterTextToRecognize,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.colorScheme.error.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
