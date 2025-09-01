import 'package:flutter/material.dart';
import '../../helpers/app_theme.dart';

class AnimatedAuthForm extends StatelessWidget {
  final Animation<double> slideController;
  final Animation<double> exitController;
  final Animation<double> formFade;
  final bool isDarkMode;
  final double heightFactor; // how much of the screen height the form should take
  final Widget? logo; // custom logo widget
  final String? title;
  final String? subtitle;
  final String? errorMessage;
  final List<Widget> fields; // pass email, password, or any other fields
  final Widget? actionButton; // login/signup button
  final List<Widget>? bottomWidget; // extra widgets at the bottom like forgot password or sign up link

  const AnimatedAuthForm({
    Key? key,
    required this.slideController,
    required this.exitController,
    required this.formFade,
    required this.isDarkMode,
    this.heightFactor = 0.75,
    this.logo,
    this.title,
    this.subtitle,
    this.errorMessage,
    required this.fields,
    this.actionButton,
    this.bottomWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
      animation: Listenable.merge([slideController, exitController]),
      builder: (context, child) {
        double slideValue = slideController.value;
        double exitValue = exitController.value;

        double bottomPosition =
            -100 + (slideValue * 100) - (exitValue * (screenHeight + 200));

        return Positioned(
          bottom: bottomPosition,
          left: 0,
          right: 0,
          child: Container(
            height: screenHeight * heightFactor,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppTheme.headerGradient(isDarkMode),
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: FadeTransition(
              opacity: formFade,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    if (logo != null) logo!,

                    const SizedBox(height: 32),

                    if (title != null)
                      Text(
                        title!,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),

                    const SizedBox(height: 8),

                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                    const SizedBox(height: 40),

                    if (errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                errorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Fields
                    ...fields.map((f) => Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: f,
                        )),

                    if (actionButton != null) actionButton!,

                    if (bottomWidget != null) ...bottomWidget!,

                    const SizedBox(height: 40),
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
