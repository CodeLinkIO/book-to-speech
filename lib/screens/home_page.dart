import 'dart:convert';
import 'dart:io' as Io;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';

import '../values.dart';
import 'detail_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String parsedtext = '';
  bool isLoaded = false;

  parseTheText(width, height) async {
//    final imageFile = await ImagePicker()
//        .pickImage(source: ImageSource.gallery, maxWidth: width, maxHeight: height);
    final ImagePicker _picker = ImagePicker();

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, maxWidth: width, maxHeight: height);

    setState(() {
      isLoaded = true;
    });
    print(image!.path);
    List<int> bytes = await image!.readAsBytes();
    String img64 = base64Encode(bytes);
    var url = 'https://api.ocr.space/parse/image';
    var payload = {"base64Image": "data:image/jpg;base64,${img64.toString()}"};
    var header = {"apikey": ocrApiKey};
    try {
	    var post = await http.post(Uri.parse(url), body: payload, headers: header);
	    var result = jsonDecode(post.body);
	    print(result);
	    String text = result['ParsedResults'][0]['ParsedText'];
//    setState(() {
//      isLoaded = false;
//    });
	    Navigator.push(
		    context,
		    PageTransition(
			    type: PageTransitionType.bottomToTop,
			    child: DetailScreen(text: text, img64: img64),
			    duration: const Duration(milliseconds: 350),
		    ),
	    );
    } catch (error) {
    	print(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: <Color>[
                Color(0xFFF9DFB2),
                Color(0xFFE9B1BD),
                Color(0xFFDBCDEB)
              ], // red to yellow
            ),
          ),
          child: Center(
            child: SizedBox(
              height: width / 2,
              width: width / 2,
              child: GestureDetector(
                onTap: () {
                  parseTheText(width, height);
                },
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset:
                            const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Center(
                    child: !isLoaded
                        ? Lottie.asset('assets/lottie/upload.json')
                        : Lottie.asset('assets/lottie/uploading.json'),
                  ),
                ),
              ),
            ),
          ),
//          child: SingleChildScrollView(
//            child: Column(
//              children: <Widget>[
//                Container(
//                  margin: const EdgeInsets.only(top: 30.0),
//                  alignment: Alignment.center,
//                  child: Text(
//                    "OCR APP",
//                    style: GoogleFonts.montserrat(
//                        fontWeight: FontWeight.w700, fontSize: 20),
//                    textAlign: TextAlign.center,
//                  ),
//                ),
//                const SizedBox(height: 15.0),
//                SizedBox(
//                  width: MediaQuery.of(context).size.width / 2,
//                  child: RaisedButton(
//                    onPressed: () => parseTheText(),
//                    child: Text(
//                      'Upload a image',
//                      style: GoogleFonts.montserrat(
//                          fontSize: 20, fontWeight: FontWeight.w700),
//                    ),
//                  ),
//                ),
//                const SizedBox(height: 70.0),
//                Container(
//                  alignment: Alignment.center,
//                  child: Column(
//                    children: <Widget>[
//                      Text(
//                        "ParsedText is:",
//                        style: GoogleFonts.montserrat(
//                            fontSize: 20, fontWeight: FontWeight.bold),
//                      ),
//                      const SizedBox(height: 10.0),
//                      Text(
//                        parsedtext,
//                        style: GoogleFonts.montserrat(
//                            fontSize: 25, fontWeight: FontWeight.bold),
//                      )
//                    ],
//                  ),
//                )
//              ],
//            ),
//          ),
        ),
      ),
    );
  }
}
