import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:billblaze/components/elevated_button.dart';
import 'package:billblaze/home.dart';
import 'package:billblaze/providers/url_provider.dart';
import 'package:billblaze/util/static_noise.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:cool_background_animation/cool_background_animation.dart';
import 'package:cool_background_animation/custom_model/enums/enum.dart';
import 'package:custom_border/border.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:billblaze/colors.dart';
import 'package:billblaze/providers/auth_provider.dart';
import 'package:flutter_svgl/flutter_svgl.dart';
import 'package:iconsax_plus/iconsax_plus.dart';


class LoginSignUp extends StatefulWidget {
  final bool withClose;

  const LoginSignUp({super.key, this.withClose = false});

  @override
  State<LoginSignUp> createState() => _LoginSignUpState();
}

class _LoginSignUpState extends State<LoginSignUp> {
  InAppWebViewController? _controller;
  TextEditingController emailFieldController = TextEditingController();
  TextEditingController passwordFieldController = TextEditingController();
  FocusNode emailFieldFocusNode = FocusNode();
  FocusNode passwordFieldFocusNode = FocusNode();
  String errorText = 'Enter a valid email';
  @override
  void initState() {
    super.initState();
    emailFieldController.addListener(() {
    setState(() {}); // rebuilds to re-check height
  });
  }
  bool isEmailValid(String email) {
    if (email.isEmpty) return true;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    print(emailRegex.hasMatch(email));
    return emailRegex.hasMatch(email);
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller?.dispose();
  }
  @override
  Widget build(BuildContext context) {
    double sWidth = MediaQuery.of(context).size.width;
    double sHeight = MediaQuery.of(context).size.height;
    double titleFontSize = sHeight / 9;
    return Consumer(builder: (context, ref, c) {
      return Scaffold(
        backgroundColor: defaultPalette.primary,
        body: Stack(
          children: [
            Opacity(
                  opacity: 0.35,
                  child: LineChart(LineChartData(
                    lineBarsData: [LineChartBarData()],
                    titlesData: const FlTitlesData(show: false),
                    gridData: FlGridData(
                      getDrawingVerticalLine: (value) => FlLine(
                        color: defaultPalette.extras[0].withOpacity(0.7),
                        dashArray:[2,8],
                        strokeWidth: 1),
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: defaultPalette.extras[0].withOpacity(0.7),
                        dashArray:[2,8],
                        strokeWidth: 1),
                      show: true,
                      horizontalInterval: 10,
                      verticalInterval: 30),
                    borderData: FlBorderData(show: false),
                    minY: 0,
                    maxY: 50,
                    maxX: DateTime.now().millisecondsSinceEpoch
                                .ceilToDouble() /
                            500 +
                        250,
                    minX: DateTime.now().millisecondsSinceEpoch
                            .ceilToDouble() /
                        500)),
                ),
                 
            //BILLBLAZE MAIN TITLE
            AnimatedPositioned(
              duration: Durations.medium3,
              top: 60,
              left: 70,
              child: Hero(
                tag: 'login',
                child: AnimatedTextKit(
                  key: ValueKey(sHeight*sWidth),
                  animatedTexts: [
                    TypewriterAnimatedText(
                      "Bill\nBlaze.",
                      textStyle: GoogleFonts.abrilFatface(
                          fontSize: titleFontSize,
                          color: defaultPalette.extras[0],
                          height: 0.9),
                      speed: const Duration(milliseconds: 100)),
                    TypewriterAnimatedText(
                      "Bill\nBlaze.",
                      textStyle: GoogleFonts.zcoolKuaiLe(
                          fontSize:titleFontSize,
                          color: Colors.black,
                          height: 0.9),
                      speed: const Duration(milliseconds: 100)),
                    TypewriterAnimatedText(
                      "Bill\nBlaze.",
                      textStyle: GoogleFonts.ballet(
                          fontSize: titleFontSize,
                          color:Colors.black,
                          height: 0.9),
                      speed: const Duration(milliseconds: 100)),
                    TypewriterAnimatedText(
                      "Bill\nBlaze",
                      textStyle: GoogleFonts.moiraiOne(
                          fontSize: titleFontSize ,
                          letterSpacing: -0.5,
                          height: 1),
                      speed: const Duration(milliseconds: 100)),
                    TypewriterAnimatedText(
                      "Bill\nBlaze.",
                      textStyle: GoogleFonts.redactedScript(
                          fontSize: titleFontSize,
                          color: Colors.black,
                          height: 0.9),
                      speed: const Duration(milliseconds: 100)),
                    TypewriterAnimatedText("Bill\nBlaze.",
                        textStyle: GoogleFonts.silkscreen(
                            fontSize: titleFontSize,
                            color: Colors.black,
                            height: 0.9),
                        speed: const Duration(milliseconds: 100)),
                    // TypewriterAnimatedText("Bill\nBlaze.",
                    //     textStyle: GoogleFonts.nabla(
                    //         fontSize: isHomeTab
                    //             ? titleFontSize
                    //             : titleFontSize / 3,
                    //         color: isHomeTab
                    //             ? Colors.black
                    //             : Color(0xFF000000).withOpacity(0.8),
                    //         height: 0.9),
                    //     speed: Duration(milliseconds: 100)),
                  ],
                  // totalRepeatCount: 1,
                  repeatForever: true,
                  pause: const Duration(milliseconds: 30000),
                  displayFullTextOnTap: true,
                  stopPauseOnTap: true,
                ),
              ),
            ),
            //leftSideButtons and elevated
            Positioned(
              bottom:-90,left: 50,
              child: Container(
              height: sHeight-(2*titleFontSize),
              width: (15+65+15+65+15+65+15+65)+mapValueDimensionBased(0, 200, sWidth, sHeight,useWidth: true),
                 
              decoration: BoxDecoration(
                color: defaultPalette.transparent,
                borderRadius: BorderRadius.circular(45),
                border: Border.all(width: 1.5,color: defaultPalette.extras[0],),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 15+mapValueDimensionBasedLockOnDesync(0, 5, sWidth, sHeight),),
                     Expanded(
                       child: Container(
                        margin: EdgeInsets.all(0)
                        .copyWith(top: 15+mapValueDimensionBasedLockOnDesync(0, 5, sWidth, sHeight)),
                         child: Column(
                           children: [
                            Text(
                              ' LOGIN',
                              maxLines:1,
                              overflow:TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lexend(
                                fontSize: mapValueDimensionBased(12, 25, sWidth, sHeight, ),
                                color: defaultPalette.extras[0],
                                letterSpacing: mapValueDimensionBased(5, 15, sWidth, sHeight,),
                                height: 1,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: mapValueDimensionBasedLockOnDesync(25, 35, sWidth, sHeight),),
                            //email textfield
                            SizedBox(
                              height:mapValueDimensionBasedLockOnDesync(isEmailValid(emailFieldController.text)?30:50,isEmailValid(emailFieldController.text)? 65:85, sWidth, sHeight) ,
                              child: TextFormField(
                                controller: emailFieldController,
                                keyboardType: TextInputType.emailAddress,
                                focusNode: emailFieldFocusNode,
                                style: GoogleFonts.lexend(
                                  color: defaultPalette.extras[0],
                                  letterSpacing: -1,
                                  fontSize: mapValueDimensionBasedLockOnDesync(15, 45, sWidth, sHeight),
                                ),
                                cursorColor: defaultPalette.tertiary,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return null;
                                  }
                                  if (!isEmailValid(value)) {
                                    return errorText;
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(left: 10),
                                  hintText: '',
                                  focusColor: defaultPalette.extras[0],
                                  hintStyle: GoogleFonts.lexend(
                                    color: defaultPalette.extras[0],
                                    letterSpacing: -1,
                                    fontSize: 15,
                                  ),
                                  prefixIcon: Icon(
                                    TablerIcons.mail,
                                    size: mapValueDimensionBasedLockOnDesync(25, 35, sWidth, sHeight),
                                    color: defaultPalette.extras[0],
                                  ),
                                  errorStyle:GoogleFonts.lexend(
                                    color: defaultPalette.extras[0],
                                    letterSpacing: -1,
                                    fontSize: mapValueDimensionBasedLockOnDesync(12, 25, sWidth, sHeight),
                                  ),errorMaxLines: 1,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(width: 0.5, color: defaultPalette.extras[0]),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(width: 2, color: defaultPalette.tertiary),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(width: 2, color: errorText == 'be a darling & use google login 🤗✨'?Colors.blue: Colors.red),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(width: 2, color: Colors.red),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                              ),
                            ),
                            SizedBox(height: mapValueDimensionBasedLockOnDesync(isEmailValid(emailFieldController.text)?15:5, isEmailValid(emailFieldController.text)?25:15, sWidth, sHeight),),
                            //password textfield
                            SizedBox(
                              height:mapValueDimensionBasedLockOnDesync(30, 65, sWidth, sHeight) ,
                              child: TextFormField(
                                style: GoogleFonts.redactedScript(
                                color: defaultPalette.extras[0],
                                letterSpacing:-1,
                                fontSize: mapValueDimensionBasedLockOnDesync(15, 45, sWidth, sHeight) ,
                                ),
                                onChanged: (value) {},
                                
                                cursorColor: defaultPalette.tertiary,
                                controller: passwordFieldController,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(0).copyWith(left: 10,),
                                  hintText: '',
                                  focusColor: defaultPalette.extras[0],
                                  hintStyle: GoogleFonts.lexend(
                                    color: defaultPalette.extras[0],
                                    letterSpacing:-1,
                                    fontSize: 15),
                                  prefixIcon: Icon(TablerIcons.password, size:mapValueDimensionBasedLockOnDesync(25, 35, sWidth, sHeight),
                                      color: defaultPalette.extras[0]),
                                  focusedBorder:  OutlineInputBorder(
                                    borderSide: BorderSide(width: 2, color: defaultPalette.tertiary), 
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(width: 0.5, color: defaultPalette.extras[0]), 
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: mapValueDimensionBasedLockOnDesync(15, 25, sWidth, sHeight),),
                            Text(
                                'OR    ',
                                maxLines:1,
                                overflow:TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                                style: GoogleFonts.lexend(
                                  fontSize: mapValueDimensionBased(12, 25, sWidth, sHeight, ),
                                  color: defaultPalette.extras[0],
                                  letterSpacing: mapValueDimensionBased(5, 15, sWidth, sHeight,),
                                  height: 1,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                           ],
                         ),
                       ),
                     ),
                     SizedBox(width: mapValueDimensionBasedLockOnDesync(25, 35, sWidth, sHeight),),
                    Column(
                      children: [
                        SizedBox(height: 15+mapValueDimensionBasedLockOnDesync(0, 5, sWidth, sHeight),),
                        ElevatedLayerButton(
                        depth: 3, subfac: 3,
                        onClick:() async {
                          // ref.read(loginPageUrlProvider.notifier).state ="https://www.youtube.com/watch?v=XY4jS4X09zY&t=148s&pp=0gcJCTAAlc8ueATH";
                          // if (_controller != null && ref.read(loginPageUrlProvider).isNotEmpty) {
                          //     // startWhiteNoise();
                          //     await _controller!.loadUrl(
                          //       urlRequest: URLRequest(url: WebUri("D:/Jepixo/CurrYaar/App/billblaze/assets/static.html")),
                          //     );
                          //     await Future.delayed(const Duration(milliseconds: 100));
                          //     startWhiteNoise();
                          //     await Future.delayed(const Duration(milliseconds: 400));
                          //     await _controller!.loadUrl(
                          //       urlRequest: URLRequest(url: WebUri.uri(Uri.parse(ref.read(loginPageUrlProvider)))),
                          //     );
                          //     stopWhiteNoise();
                          //     await Future.delayed(const Duration(milliseconds: 100));
                          //   }
                          //   setState(() {
                              
                          //   });
                          if (isEmailValid(emailFieldController.text) && passwordFieldController.text.isNotEmpty) {
                            setState(() {
                              errorText = 'be a darling & use google login 🤗✨';
                              emailFieldController.text = 'ahaa just kidding';
                              passwordFieldController.text = "have a lovely day while you're at it would ya?";
                              
                            });
                          }
                        },
                        buttonHeight: mapValueDimensionBasedLockOnDesync(75, 130, sWidth, sHeight),
                        buttonWidth: mapValueDimensionBasedLockOnDesync(75, 130, sWidth, sHeight),
                        borderRadius:
                            BorderRadius.circular(450000),
                        animationDuration:
                            const Duration(milliseconds: 100),
                        animationCurve: Curves.ease,
                        topDecoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(),
                        ),
                        topLayerChild: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(IconsaxPlusLinear.login_1, size: mapValueDimensionBasedLockOnDesync(55, 100, sWidth, sHeight),)
                          ],
                        ),
                        baseDecoration: BoxDecoration(
                          color: defaultPalette.extras[0],
                          border: Border.all(),
                        ),
                        ),
                        SizedBox(height: 15+mapValueDimensionBasedLockOnDesync(0, 5, sWidth, sHeight),),
                        ElevatedLayerButton(
                          // isTapped: false,
                          // toggleOnTap: true,
                          depth: 3, subfac: 3,
                          onClick: () async {
                            
                            ref.read(loginPageUrlProvider.notifier).state ="https://github.com/jepixo";
                            if (_controller != null && ref.read(loginPageUrlProvider).isNotEmpty) {
                              // startWhiteNoise();
                              await _controller!.loadUrl(
                                urlRequest: URLRequest(url: WebUri("D:/Jepixo/CurrYaar/App/billblaze/assets/static.html")),
                              );
                              await Future.delayed(const Duration(milliseconds: 100));
                              startWhiteNoise();
                              await Future.delayed(const Duration(milliseconds: 400));
                              _controller!.loadUrl(
                                urlRequest: URLRequest(url: WebUri.uri(Uri.parse(ref.read(loginPageUrlProvider)))),
                              );
                              stopWhiteNoise();
                              await Future.delayed(const Duration(milliseconds: 100));
                            }
                            setState(() {
                              
                            });
                          },
                          buttonHeight: mapValueDimensionBasedLockOnDesync(75, 130, sWidth, sHeight),
                          buttonWidth: mapValueDimensionBasedLockOnDesync(75, 130, sWidth, sHeight),
                          borderRadius:
                              BorderRadius.circular(450000),
                          animationDuration:
                              const Duration(milliseconds: 100),
                          animationCurve: Curves.ease,
                          topDecoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(),
                          ),
                          topLayerChild: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SVGL.software.githubLight(
                                width: mapValueDimensionBasedLockOnDesync(55, 100, sWidth, sHeight),
                                height: mapValueDimensionBasedLockOnDesync(55, 100, sWidth, sHeight))
                            ],
                          ),
                          baseDecoration: BoxDecoration(
                            color: defaultPalette.extras[0],
                            border: Border.all(),
                          ),
                        ),
                        SizedBox(height: 15+mapValueDimensionBasedLockOnDesync(0, 5, sWidth, sHeight),),
                        Expanded(child: SizedBox())
                      ],
                    ),  
                    SizedBox(width: 15+mapValueDimensionBasedLockOnDesync(0, 5, sWidth, sHeight),),
                    
                    
                  ],
                ),
              ),
            ),
            //TVTV
            Positioned(
              bottom:-90,right: mapValueDimensionBased(50, 60, sWidth, sHeight,useWidth: true),
              child:ElevatedLayerButton(
                // isTapped: false,
                // toggleOnTap: true,
                depth:4, subfac: 4,
                onClick: () {
                },
                buttonWidth: (sWidth -(15+65+15+65+15+65+15+65+65)-80-mapValueDimensionBased(0, 200, sWidth, sHeight,useWidth: true)).clamp(0, double.infinity),
                buttonHeight: sHeight-(2*titleFontSize),
                borderRadius:
                    BorderRadius.circular(35),
                animationDuration:
                    const Duration(milliseconds: 100),
                animationCurve: Curves.ease,
                topDecoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(),
                ),
                topLayerChild: Container(
                  padding: const EdgeInsets.all(9),
                  color: Colors.white.withOpacity(0.2),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 70,
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius:BorderRadius.circular(30),
                                child: 
                                InAppWebView(
                                  initialUrlRequest: URLRequest(url: WebUri.uri(Uri.parse(ref.watch(loginPageUrlProvider)))),
                                  onWebViewCreated: (controller) async {
                                    _controller = controller;
                                    
                                    print("WebView created");
                                  },
                                  onLoadStop: (controller, url) async {
                                    
                                    print("Loaded: $url");
                                    await controller.evaluateJavascript(source: "document.documentElement.style.zoom = '100%';");
                                    
                                  },
                                  initialSettings: InAppWebViewSettings(
                                    textZoom: 50,
                                    horizontalScrollBarEnabled: false,
                                    verticalScrollBarEnabled: false,
                                    builtInZoomControls: true,
                                    pageZoom: 10,
                                    supportZoom: true,
                                    displayZoomControls: true,
                                    maximumZoomScale: 0.5
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 50,)
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 30,
                        child: Stack(
                          children: [
                            //speaker graph of the TV
                            Container(
                              margin: EdgeInsets.all(0).copyWith(left: 10),
                              decoration: BoxDecoration(
                                color: defaultPalette.secondary.withAlpha(50),
                                border: Border.all(width: 0.2),
                                borderRadius: BorderRadius.circular(30)
                              ),
                              child: ClipRRect(
                          borderRadius:BorderRadius.circular(30),
                                child: Opacity(
                                  opacity: 0.35,
                                  child: LineChart(LineChartData(
                                    lineBarsData: [LineChartBarData()],
                                    titlesData: const FlTitlesData(show: false),
                                    gridData: FlGridData(
                                      getDrawingVerticalLine: (value) => FlLine(
                                        color: defaultPalette.extras[0].withOpacity(0.7),
                                        dashArray:[2,8],
                                        strokeWidth: 0.5),
                                      getDrawingHorizontalLine: (value) => FlLine(
                                        color: defaultPalette.extras[0].withOpacity(0.7),
                                        dashArray:[2,8],
                                        strokeWidth: 0.5),
                                      show: true,
                                      horizontalInterval: 1,
                                      verticalInterval: 60),
                                    borderData: FlBorderData(show: false),
                                    minY: 0,
                                    maxY: 50,
                                    maxX: DateTime.now().millisecondsSinceEpoch
                                                .ceilToDouble() /
                                            500 +
                                        250,
                                    minX: DateTime.now().millisecondsSinceEpoch
                                            .ceilToDouble() /
                                        500)),
                                ),
                              ),
                            ),
                          
                            Column(
                              children: [
                                SizedBox(height: mapValueDimensionBased(25, 55, sWidth, sHeight,),),
                                Row(
                                  children: [
                                    SizedBox(width: mapValueDimensionBased(5, 1, sWidth, sHeight,),),
                                    Expanded(
                                      child: Text(
                                        ' FLUX',
                                        maxLines:1,
                                        overflow:TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.lexend(
                                          fontSize: mapValueDimensionBased(12, 35, sWidth, sHeight, ),
                                          color: defaultPalette.extras[0],
                                          letterSpacing: mapValueDimensionBased(5, 15, sWidth, sHeight,),
                                          height: 1,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Expanded(child: SizedBox()),
                                Row(
                                  children: [
                                    SizedBox(width: 10,),
                                    Expanded(
                                      child: Center(
                                        child: ElevatedLayerButton(
                                        // isTapped: false,
                                        // toggleOnTap: true,
                                        depth: 3, subfac: 3,
                                        onClick:() async {
                                          ref.read(loginPageUrlProvider.notifier).state =loginPageUrls[Random().nextInt(loginPageUrls.length-1)];
                                          if (_controller != null && ref.read(loginPageUrlProvider).isNotEmpty) {
                                              // startWhiteNoise();
                                              await _controller!.loadUrl(
                                                urlRequest: URLRequest(url: WebUri("D:/Jepixo/CurrYaar/App/billblaze/assets/static.html")),
                                              );
                                              await Future.delayed(const Duration(milliseconds: 100));
                                              startWhiteNoise();
                                              await Future.delayed(const Duration(milliseconds: 400));
                                              _controller!.loadUrl(
                                                urlRequest: URLRequest(url: WebUri.uri(Uri.parse(ref.read(loginPageUrlProvider)))),
                                              );
                                              await Future.delayed(const Duration(milliseconds: 100));
                                              stopWhiteNoise();
                                            }
                                            setState(() {
                                              
                                            });
                                        },
                                        buttonHeight: mapValueDimensionBasedLockOnDesync(30, 80, sWidth, sHeight),
                                        buttonWidth: mapValueDimensionBasedLockOnDesync(30, 80, sWidth, sHeight),
                                        borderRadius:
                                            BorderRadius.circular(450000),
                                        animationDuration:
                                            const Duration(milliseconds: 100),
                                        animationCurve: Curves.ease,
                                        topDecoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(),
                                        ),
                                        topLayerChild: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(TablerIcons.rosette_filled,size: mapValueDimensionBasedLockOnDesync(15, 45, sWidth, sHeight),)
                                          ],
                                        ),
                                        baseDecoration: BoxDecoration(
                                          color: defaultPalette.extras[0],
                                          border: Border.all(),
                                        ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: ElevatedLayerButton(
                                        // isTapped: false,
                                        // toggleOnTap: true,
                                        depth: 3, subfac: 3,
                                        onClick: () async {
                                          final urls = loginPageUrls;
                                          if (urls.isEmpty) return; // nothing to do

                                          final current = ref.read(loginPageUrlProvider);
                                          final idx = urls.indexOf(current); // -1 if not found
                                          final nextIndex = (idx == -1) ? 0 : (idx + 1) % urls.length;

                                          // update provider
                                          ref.read(loginPageUrlProvider.notifier).state = urls[nextIndex];

                                          // load into webview if available
                                          final newUrl = ref.read(loginPageUrlProvider);
                                          if (_controller != null && newUrl.isNotEmpty) {
                                            // startWhiteNoise();
                                            await _controller!.loadUrl(
                                              urlRequest: URLRequest(url: WebUri("D:/Jepixo/CurrYaar/App/billblaze/assets/static.html")),
                                            );
                                            await Future.delayed(const Duration(milliseconds: 100));
                                            startWhiteNoise();
                                            await Future.delayed(const Duration(milliseconds: 400));
                                            _controller!.loadUrl(
                                              urlRequest: URLRequest(url: WebUri.uri(Uri.parse(newUrl))),
                                            );
                                            await Future.delayed(const Duration(milliseconds: 100));
                                            stopWhiteNoise();
                                          }

                                          setState(() {}); // if you still need local UI refresh
                                        },

                                        buttonHeight: mapValueDimensionBasedLockOnDesync(30, 80, sWidth, sHeight),
                                        buttonWidth: mapValueDimensionBasedLockOnDesync(30, 80, sWidth, sHeight),
                                        borderRadius:
                                            BorderRadius.circular(450000),
                                        animationDuration:
                                            const Duration(milliseconds: 100),
                                        animationCurve: Curves.ease,
                                        topDecoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(),
                                        ),
                                        topLayerChild: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(TablerIcons.blob_filled,size:  mapValueDimensionBasedLockOnDesync(14, 40, sWidth, sHeight),)
                                          ],
                                        ),
                                        baseDecoration: BoxDecoration(
                                          color: defaultPalette.extras[0],
                                          border: Border.all(),
                                        ),
                                        ),
                                      ),
                                    ),
                                    
                                    SizedBox(width: mapValueDimensionBased(0, 0, sWidth, sHeight,),),
                                  ],
                                ),
                                SizedBox(height: mapValueDimensionBasedLockOnDesync(10, 50, sWidth, sHeight),),
                                GestureDetector(
                                  onTap: () {
                                    final url = ref.read(loginPageUrlProvider);
                                    Clipboard.setData(ClipboardData(text: url));
                                  },
                                  child: Container(
                                        height:mapValueDimensionBasedLockOnDesync(15, 50, sWidth, sHeight),
                                        margin: EdgeInsets.all(0).copyWith(left: 10+mapValueDimensionBasedLockOnDesync(6, 20, sWidth, sHeight),right: mapValueDimensionBasedLockOnDesync(6, 20, sWidth, sHeight)),
                                        decoration: BoxDecoration(
                                          color: defaultPalette.extras[0],
                                          borderRadius: BorderRadius.circular(50)
                                        ),
                                        padding: EdgeInsets.all(0).copyWith(left: 10,right: 10),
                                        alignment: Alignment(0,0),
                                        child:
                                         Row(
                                           children: [
                                            Text(
                                              ' //',
                                              maxLines:1,
                                              overflow:TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.lexend(
                                                fontSize: mapValueDimensionBased(8, 25, sWidth, sHeight, ),
                                                color: defaultPalette.primary,
                                                letterSpacing:-1,
                                                height: 1,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                             Expanded(
                                               child: Text(
                                                ref.watch(loginPageUrlProvider),
                                                maxLines:1,
                                                overflow:TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.redactedScript(
                                                  fontSize: mapValueDimensionBased(8, 25, sWidth, sHeight, ),
                                                  color: defaultPalette.primary,
                                                  letterSpacing:-1,
                                                  height: 1,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                                                         ),
                                             ),
                                           ],
                                         ),
                                      ),
                                ),
                                SizedBox(height: 90,),
                              ],
                            ),
                          
                          ],
                        ))
                    ],
                  ),
                ),
                  
                baseDecoration: BoxDecoration(
                  color: defaultPalette.extras[0],
                ),
              ),
                ),
            
            //BIG GOOGLE BUTTON
            Positioned(
            bottom:-40,left: 5, 
            child: ElevatedLayerButton(
              // isTapped: false,
              // toggleOnTap: true,
              depth: 3, subfac: 3,
              onClick:() async {
                await ref.read(authRepositoryProvider).googleLogin(ref);
              },
              buttonHeight:mapValueDimensionBasedLockOnDesync(200, 350, sWidth, sHeight),
              buttonWidth: mapValueDimensionBasedLockOnDesync(200, 350, sWidth, sHeight),
              borderRadius:
                  BorderRadius.circular(450000000),
              animationDuration:
                  const Duration(milliseconds: 100),
              animationCurve: Curves.ease,
              topDecoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(),
              ),
              topLayerChild: ClipRRect(
                borderRadius:
                  BorderRadius.circular(45),
                child: Stack(
                  children: [
                    // StarryBackground(
                    //   numberOfStars: 200,
                    //   starConfig: StarConfig(
                    //     minSize: 0.1,
                    //     maxSize: 1.0,
                    //     starColor: defaultPalette.primary,
                    //     movementSpeed: 2.0,
                    //     enableTwinkling: true,
                    //   ),
                    //   backgroundGradient: LinearGradient(
                    //     colors: [defaultPalette.extras[0], Color(0xFF000D36)],
                    //   ),
                    //   enableShootingStars: true,
                    //   shootingStarInterval: Duration(seconds: 3),
                    // ),
                    SVGL.google.google(
                              width: mapValueDimensionBasedLockOnDesync(150, 280, sWidth, sHeight),
                              height: mapValueDimensionBasedLockOnDesync(150, 280, sWidth, sHeight))
                  ],
                )
                ),
              baseDecoration: BoxDecoration(
                color: defaultPalette.extras[0],
                border: Border.all(),
              ),
            ),
            ),
            
            // Windows top bar
            if (Platform.isWindows)
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanStart: (details) {
                appWindow.startDragging();
              },
              onDoubleTap: () {
                appWindow.maximizeOrRestore();
              },
              child: SizedBox(
                height: 40,
                width: sWidth,
              ),
            ),
            if (Platform.isWindows)
            Consumer(builder: (context, ref, c) {
                return Stack(
                  children: [
                    AnimatedPositioned(
                      right: 3,
                      top: 5,
                      duration: Durations.short4,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: AnimatedContainer(
                          duration: Durations.short4,
                          padding: const EdgeInsets.only(
                              right: 6, bottom: 0),
                          margin: const EdgeInsets.only(top: 5),
                          decoration: const BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              )),
                          child: Column(
                            children: [
                              //close button
                              ElevatedLayerButton(
                                // isTapped: false,
                                // toggleOnTap: true,
                                depth: 3, subfac:3,
                                onClick: () {
                                  Future.delayed(Duration.zero)
                                      .then((y) {
                                    appWindow.close();
                                  });
                                },
                                buttonHeight: mapValueDimensionBasedLockOnDesync(35, 50, sWidth, sHeight),
                                buttonWidth: mapValueDimensionBasedLockOnDesync(35, 50, sWidth, sHeight),
                                borderRadius:
                                    BorderRadius.circular(50),
                                animationDuration:
                                    const Duration(milliseconds: 1),
                                animationCurve: Curves.ease,
                                topDecoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(),
                                ),
                                topLayerChild:  const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      TablerIcons.circle_filled,
                                      size: 15,
                                      color: Colors.red,
                                    ),
                                    
                                  ],
                                ),
                                baseDecoration: BoxDecoration(
                                  color: defaultPalette.extras[0],
                                  border: Border.all(),
                                ),
                              ),
                            SizedBox(height: 7,),
                              //
                              //maximize button
                              ElevatedLayerButton(
                                // isTapped: false,
                                // toggleOnTap: true,
                                depth: 3, subfac:3,
                                onClick: () {
                                  Future.delayed(Durations.short1)
                                      .then((y) {
                                    appWindow.maximizeOrRestore();
                                  });
                                },
                                buttonHeight: mapValueDimensionBasedLockOnDesync(35, 50, sWidth, sHeight),
                                buttonWidth: mapValueDimensionBasedLockOnDesync(35, 50, sWidth, sHeight),
                                borderRadius:
                                    BorderRadius.circular(50),
                                animationDuration:
                                    const Duration(milliseconds: 1),
                                animationCurve: Curves.ease,
                                topDecoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(),
                                ),
                                topLayerChild:  const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      TablerIcons.triangle_filled,
                                      size: 15,
                                      color: Colors.green,
                                    ),
                                    
                                  ],
                                ),
                                baseDecoration: BoxDecoration(
                                  color: defaultPalette.extras[0],
                                  border: Border.all(),
                                ),
                              ),
                              SizedBox(height: 7,),
                              
                              //minimize button
                              ElevatedLayerButton(
                                // isTapped: false,
                                // toggleOnTap: true,
                                depth: 3, subfac: 3,
                                onClick: () {
                                  Future.delayed(Duration.zero)
                                      .then((y) {
                                    appWindow.minimize();
                                  });
                                },
                                buttonHeight: mapValueDimensionBasedLockOnDesync(35, 50, sWidth, sHeight),
                                buttonWidth: mapValueDimensionBasedLockOnDesync(35, 50, sWidth, sHeight),
                                borderRadius:
                                    BorderRadius.circular(50),
                                animationDuration:
                                    const Duration(milliseconds: 10),
                                animationCurve: Curves.ease,
                                topDecoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(),
                                ),
                                topLayerChild: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      TablerIcons.rectangle_filled,
                                      size: 15,
                                      color: Colors.blue,
                                    ),
                                    
                                  ],
                                ),
                                baseDecoration: BoxDecoration(
                                  color: defaultPalette.extras[0],
                                  border: Border.all(),
                                ),
                              ),
                              
                            ],
                          ),
                          //
                        ),
                      ),
                    ),
                  ],
                );
              }),
          
          ],
        ),
      );
    });
  }
}
