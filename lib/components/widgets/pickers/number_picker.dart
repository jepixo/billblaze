import 'dart:async';
import 'package:billblaze/colors.dart';
import 'package:billblaze/home.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Shows a month picker dialog.
///
/// [initialDate] is the initially selected month.
/// [firstDate] is the lower bound for month selection.
/// [lastDate] is the upper bound for month selection.
///
Future<DateTime?> showMonthPicker({
  required BuildContext context,
  Locale? locale,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  TransitionBuilder? builder,
}) async {
  return await showDialog<DateTime>(
    context: context,
    builder: (context) {
      Widget dialog = _MonthPickerDialog(
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
      );

      if (locale != null) {
        dialog = Localizations.override(
          context: context,
          locale: locale,
          child: dialog,
        );
      }

      if (builder != null) {
        dialog = builder(context, dialog);
      }

      return dialog;
    },
  );
}

class _MonthPickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const _MonthPickerDialog({
    Key? key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  }) : super(key: key);

  @override
  _MonthPickerDialogState createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<_MonthPickerDialog> {
  final _pageViewKey = GlobalKey();
  late final PageController _pageController;
  late final DateTime _firstDate;
  late final DateTime _lastDate;
  late DateTime _selectedDate;
  late int _displayedPage;
  bool _isYearSelection = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(widget.initialDate.year, widget.initialDate.month);
    _firstDate = DateTime(widget.firstDate.year, widget.firstDate.month);
    _lastDate = DateTime(widget.lastDate.year, widget.lastDate.month);
    _displayedPage = _selectedDate.year;
    _pageController = PageController(initialPage: _displayedPage);
  }

  String _locale(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return '${locale.languageCode}_${locale.countryCode}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = MaterialLocalizations.of(context);
    final locale = _locale(context);
    final header = _buildHeader(theme, locale);
    final pager = _buildPager(theme.colorScheme, locale);

    final borderRadius =
        MediaQuery.of(context).orientation == Orientation.portrait
            ? const BorderRadius.only(
                bottomLeft: Radius.circular(4.0),
                bottomRight: Radius.circular(4.0))
            : const BorderRadius.only(
                topRight: Radius.circular(4.0),
                bottomRight: Radius.circular(4.0));

    final content = Material(
      clipBehavior: Clip.antiAlias,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          pager,
          Container(height: 24),
          _buildButtonBar(context, localizations)
        ],
      ),
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Builder(builder: (context) {
            if (MediaQuery.of(context).orientation == Orientation.portrait) {
              return IntrinsicWidth(
                child: Column(children: [header, content]),
              );
            }
            return IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [header, content],
              ),
            );
          })
        ],
      ),
    );
  }

  Widget _buildButtonBar(
      BuildContext context, MaterialLocalizations localizations) {
    return ButtonTheme(
      child: ButtonBar(
        children: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text(localizations.cancelButtonLabel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _selectedDate),
            child: Text(localizations.okButtonLabel),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, String locale) {
    final borderRadius =
        MediaQuery.of(context).orientation == Orientation.portrait
            ? const BorderRadius.only(
                topLeft: Radius.circular(4.0), topRight: Radius.circular(4.0))
            : const BorderRadius.only(
                topLeft: Radius.circular(4.0),
                bottomLeft: Radius.circular(4.0));

    return Material(
      clipBehavior: Clip.antiAlias,
      color: theme.brightness == Brightness.dark
          ? theme.colorScheme.surface
          : theme.colorScheme.primary,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              DateFormat.yMMM(locale).format(_selectedDate),
              style: theme.primaryTextTheme.titleMedium,
            ),
            DefaultTextStyle(
              style: theme.primaryTextTheme.headlineSmall!,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  if (!_isYearSelection)
                    GestureDetector(
                      onTap: () {
                        setState(() => _isYearSelection = true);
                        _pageController.jumpToPage(_displayedPage ~/ 12);
                      },
                      child: Text(DateFormat.y(locale)
                          .format(DateTime(_displayedPage))),
                    ),
                  if (_isYearSelection)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(DateFormat.y(locale)
                            .format(DateTime(_displayedPage * 12))),
                        Text('-'),
                        Text(DateFormat.y(locale)
                            .format(DateTime(_displayedPage * 12 + 11))),
                      ],
                    ),
                  Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          Icons.keyboard_arrow_up,
                          color: theme.primaryIconTheme.color,
                        ),
                        onPressed: () => _pageController.animateToPage(
                            _displayedPage - 1,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: theme.primaryIconTheme.color,
                        ),
                        onPressed: () => _pageController.animateToPage(
                            _displayedPage + 1,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPager(ColorScheme colorScheme, String locale) {
    return SizedBox(
      height: 220.0,
      width: 300.0,
      child: PageView.builder(
          key: _pageViewKey,
          controller: _pageController,
          scrollDirection: Axis.vertical,
          onPageChanged: (index) {
            setState(() => _displayedPage = index);
          },
          pageSnapping: !_isYearSelection,
          itemBuilder: (context, page) {
            return GridView.count(
              padding: const EdgeInsets.all(8.0),
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              children: _isYearSelection
                  ? List<int>.generate(12, (i) => page * 12 + i)
                      .map(
                        (year) => Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: _getYearButton(year, colorScheme, locale),
                        ),
                      )
                      .toList()
                  : List<int>.generate(12, (i) => i + 1)
                      .map((month) => DateTime(page, month))
                      .map(
                        (date) => Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: _getMonthButton(date, colorScheme, locale),
                        ),
                      )
                      .toList(),
            );
          }),
    );
  }

  Widget _getMonthButton(
      final DateTime date, final ColorScheme colorScheme, final String locale) {
    final int? firstDateCompared = _firstDate.compareTo(date);
    final int? lastDateCompared = _lastDate.compareTo(date);

    VoidCallback? callback = (firstDateCompared == null ||
                firstDateCompared <= 0) &&
            (lastDateCompared == null || lastDateCompared >= 0)
        ? () => setState(() => _selectedDate = DateTime(date.year, date.month))
        : null;

    bool isSelected =
        date.month == _selectedDate.month && date.year == _selectedDate.year;

    return TextButton(
      onPressed: callback,
      style: TextButton.styleFrom(
        foregroundColor: isSelected
            ? colorScheme.onPrimary
            : date.month == DateTime.now().month &&
                    date.year == DateTime.now().year
                ? colorScheme.primary
                : colorScheme.onSurface.withOpacity(0.87),
        backgroundColor: isSelected ? colorScheme.primary : null,
        shape: const StadiumBorder(),
      ),
      child: Text(DateFormat.MMM(locale).format(date)),
    );
  }

  Widget _getYearButton(
      final int year, final ColorScheme colorScheme, final String locale) {
    final int? firstDateCompared = _firstDate.compareTo(DateTime(year));
    final int? lastDateCompared = _lastDate.compareTo(DateTime(year));

    VoidCallback? callback =
        (firstDateCompared == null || firstDateCompared <= 0) &&
                (lastDateCompared == null || lastDateCompared >= 0)
            ? () => setState(() {
                  _pageController.jumpToPage(year);
                  setState(() => _isYearSelection = false);
                })
            : null;

    bool isSelected = year == _selectedDate.year;

    return TextButton(
      onPressed: callback,
      style: TextButton.styleFrom(
        foregroundColor: isSelected
            ? colorScheme.onPrimary
            : year == DateTime.now().year
                ? colorScheme.primary
                : colorScheme.onSurface.withOpacity(0.87),
        backgroundColor: isSelected ? colorScheme.primary : null,
        shape: const StadiumBorder(),
      ),
      child: Text(DateFormat.y(locale).format(DateTime(year))),
    );
  }
}


// ignore: must_be_immutable
class SwitcherButton extends StatefulWidget {
  /// width and height of widget.
  /// width = size,height = size / 2.
  late double _width, _height;

  /// size of widget.
  final double size;
  final String onText;

  /// onColor is color when widget switched on,
  /// default value is: [Colors.white].
  /// offColor is color when widget switched off,
  /// default value is: [Colors.black].
  final Color onColor, offColor;

  /// status of widget, if value == true widget will switched on else
  /// switched off
  final bool value;

  /// when change status of widget like switch off or switch on [onChange] will
  /// call and passed new [value]
  final Function(bool value)? onChange;

  SwitcherButton(
      {Key? key,
      this.size = 120.0,
      this.onColor = Colors.white,
      this.offColor = Colors.black87,
      this.value = false,
      this.onText = '',
      this.onChange})
      : super(key: key) {
    _width = size;
    _height = size / 6;
  }

  @override
  _SwitcherButtonState createState() => _SwitcherButtonState();
}

class _SwitcherButtonState extends State<SwitcherButton>
    with TickerProviderStateMixin {
  
  @override
  void dispose() {
    _rightController.dispose();
    _leftController.dispose();
    super.dispose();
  }
  
  /// sate of widget that can be switched on or switched off.
  late bool value;

  /// radius of right circle.
  double _rightRadius = 0.0;

  /// radius of left circle.
  double _leftRadius = 0.0;

  /// right radius animation and left radius animation.
  late Animation<double> _rightRadiusAnimation, _leftRadiusAnimation;

  /// animation controllers.
  late AnimationController _rightController, _leftController;

  @override
  void initState() {
    value = widget.value;

    // animation controllers initialize.
    _rightController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    _leftController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    if (value) {
      // when widget initial with on state.
      _leftRadius = widget._width ;
      _rightRadiusAnimation = Tween(begin: 0.0, end: widget._height * .1)
          .animate(CurvedAnimation(
              parent: _rightController, curve: Curves.elasticOut))
            ..addListener(() {
              setState(() {
                _rightRadius = _rightRadiusAnimation.value;
              });
            });
      _rightController.forward();
    } else {
      // when widget initial with off state.
      _rightRadius = widget._width ;
      _leftRadiusAnimation = Tween(begin: 0.0, end: widget._height * .4)
          .animate(CurvedAnimation(
              parent: _leftController, curve: Curves.elasticOut))
            ..addListener(() {
              setState(() {
                _leftRadius = _leftRadiusAnimation.value;
              });
            });
      _leftController.forward();
    }

    super.initState();
  }

  @override
  void didUpdateWidget(covariant SwitcherButton oldWidget) {
    // TODO: implement didUpdateWidget
    setState(() {
      
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    var sHeight = MediaQuery.of(context).size.height;
    var sWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        if (!_rightController.isAnimating && !_leftController.isAnimating)
          _changeState();
      },
      child: Stack(
        children: [
          SizedBox(
              width: widget._width,
              height: widget._height,),
          Container(
            width: widget._width,
            height: widget._height,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(3.0))),
            child: CustomPaint(
              size: Size.infinite,
              painter: ProfileCardPainter(
                  offColor: widget.offColor,
                  onColor: widget.onColor,
                  leftRadius: _leftRadius,
                  rightRadius: _rightRadius,
                  value: value),
            ),
          ),
          Positioned(
            right: 5,
            child: Text(widget.onText,
            style: GoogleFonts.lexend(fontSize:mapValueDimensionBased(13, 19, sWidth, sHeight), color: defaultPalette.primary),
            ),
          )
        ],
      ),
    );
  }

  // change state of widget when clicked on widget.
  _changeState() {
    _rightController = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    _leftController = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);

    if (value) {
      // If value == true right radius will be 18% widget height
      // and left radius will be 2 * widget height
      // switcher is on.

      _rightController.duration = Duration(milliseconds: 400);

      _rightRadiusAnimation =
          Tween(begin: widget._height * .1, end: widget._width)
              .animate(_rightController)
                ..addStatusListener((status) {
                  if (status == AnimationStatus.completed) {
                    // when widget switched to new state(on state) and complete
                    // animation show off circle to user
                    setState(() {
                      _leftRadius = 0.0;
                      value = false;
                    });
                    _leftController.reset();
                    _leftController.duration = Duration(milliseconds: 800);
                    _leftRadiusAnimation =
                        Tween(begin: 0.0, end: widget._height * .4).animate(
                            CurvedAnimation(
                                parent: _leftController,
                                curve: Curves.elasticOut))
                          ..addListener(() {
                            setState(() {
                              _leftRadius = _leftRadiusAnimation.value;
                            });
                          });
                    _leftController.forward();
                  }
                })
                ..addListener(() {
                  setState(() {
                    _rightRadius = _rightRadiusAnimation.value;
                  });
                });
      _rightController.forward();
    } else {
      // If value == true left radius will be 18% widget height
      // and right radius will be 2 * widget height
      // switcher is off.
      _leftController.duration = Duration(milliseconds: 400);

      _leftRadiusAnimation =
          Tween(begin: widget._height * .4, end: widget._width)
              .animate(_leftController)
                ..addStatusListener((status) {
                  if (status == AnimationStatus.completed) {
                    // when widget switched to new state(off state) and complete
                    // animation show on circle to user
                    setState(() {
                      _rightRadius = 0.0;
                      value = true;
                    });
                    _rightController.reset();
                    _rightController.duration = Duration(milliseconds: 800);
                    _rightRadiusAnimation =
                        Tween(begin: 0.0, end: widget._height * .1).animate(
                            CurvedAnimation(
                                parent: _rightController,
                                curve: Curves.elasticOut))
                          ..addListener(() {
                            setState(() {
                              _rightRadius = _rightRadiusAnimation.value;
                            });
                          });
                    _rightController.forward();
                  }
                })
                ..addListener(() {
                  setState(() {
                    _leftRadius = _leftRadiusAnimation.value;
                  });
                });
      _leftController.forward();
    }

    // Call onChange
    if (widget.onChange != null) widget.onChange!(!value);
  }
}

class ProfileCardPainter extends CustomPainter {
  /// Left circle radius.
  late double rightRadius;

  /// Right circle radius.
  late double leftRadius;

  /// State of widget.
  late bool value;

  /// Color when widget is on
  late Color onColor;

  /// Color when widget is off
  late Color offColor;

  ProfileCardPainter(
      {required this.rightRadius,
      required this.leftRadius,
      required this.value,
      required this.onColor,
      required this.offColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (value) {
      var paint = Paint()
        ..color = onColor
        ..strokeWidth = 18;
      Offset center = Offset((size.width / 2) / 2, size.height / 2);
      canvas.drawCircle(center, leftRadius, paint);

      paint.color = offColor;
      center =
          Offset(((size.width / 2) / 2) + (size.width / 2), size.height / 2);
      canvas.drawCircle(center, rightRadius, paint);
    } else {
      var paint = Paint()..strokeWidth = 18;
      Offset center;

      paint.color = offColor;
      center =
          Offset(((size.width / 2) / 2) + (size.width / 2), size.height / 2);
      canvas.drawCircle(center, rightRadius, paint);

      paint.color = onColor;
      center = Offset((size.width / 2) / 2, size.height / 2);
      canvas.drawCircle(center, leftRadius, paint);
    }
  }

  @override
  bool shouldRepaint(ProfileCardPainter oldDelegate) {
    return true;
  }
}