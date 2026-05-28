import 'package:flutter/material.dart';

class AdaptiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int maxLines;
  final TextAlign textAlign;
  final double minScale;

  const AdaptiveText(
    this.text, {
    super.key,
    this.style,
    this.maxLines = 1,
    this.textAlign = TextAlign.start,
    this.minScale = 0.6,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final resolvedStyle = DefaultTextStyle.of(context).style.merge(style);
        final fontSize = resolvedStyle.fontSize ?? 14.0;
        final minFontSize = fontSize * minScale;
        final maxWidth = constraints.hasBoundedWidth ? constraints.maxWidth : double.infinity;

        double low = minFontSize;
        double high = fontSize;
        double best = fontSize;

        bool fits(double candidateSize) {
          final painter = TextPainter(
            text: TextSpan(
              text: text,
              style: resolvedStyle.copyWith(fontSize: candidateSize),
            ),
            textAlign: textAlign,
            textDirection: Directionality.of(context),
            maxLines: maxLines,
          )..layout(maxWidth: maxWidth);

          if (maxLines == 1) {
            return !painter.didExceedMaxLines && painter.width <= maxWidth;
          }
          return !painter.didExceedMaxLines &&
              painter.width <= maxWidth &&
              painter.height <= constraints.maxHeight;
        }

        if (constraints.hasBoundedWidth && maxWidth.isFinite) {
          if (fits(high)) {
            best = high;
          } else {
            for (var i = 0; i < 10; i++) {
              final mid = (low + high) / 2;
              if (fits(mid)) {
                best = mid;
                low = mid;
              } else {
                high = mid;
              }
            }
          }
        }

        return Text(
          text,
          style: resolvedStyle.copyWith(fontSize: best),
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: TextOverflow.clip,
          softWrap: maxLines != 1,
        );
      },
    );
  }
}

class AdaptiveAmountText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final double minScale;

  const AdaptiveAmountText(
    this.text, {
    super.key,
    this.style,
    this.textAlign = TextAlign.end,
    this.minScale = 0.78,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveText(
      text,
      style: style,
      textAlign: textAlign,
      minScale: minScale,
    );
  }
}
