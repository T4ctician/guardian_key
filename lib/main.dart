import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guardian Key',
      theme: ThemeData(
        fontFamily: GoogleFonts.poppins().fontFamily,
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget{
  const HomePage({super.key});

  @override
  Widget build(BuildContext context){
    const String assetName = 'assets/bell.svg';
    double screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 35, 20.0, 5),
            child: Row(
              children:[
                //profile row
                Row(
                  children: [
                    circleAvatarRound(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0)
                      child: Column(
                        children: [Text("Hello, Kenny", style: TextStyle(color: Color.fromARGB(255, 22, 22, 22), 
                        fontSize: 10, 
                        fontWeight: FontWeight.w500,
                        ),
                      )
                      ],
                    )
                  ],
                ),
                SvgPicture.asset(assetName,
                      semanticsLabel: 'bell icon', height: screenHeight * 0.035),
              ],
            ),
          )
        ],
      ))
      );
  }
    Widget circleAvatarRound() {
    return CircleAvatar(
      radius: 28,
      backgroundColor: Color.fromARGB(255, 213, 213, 213),
      child: CircleAvatar(
        radius: 26.5,
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        child: Padding(
          padding: EdgeInsets.all(5),
          child: CircleAvatar(
            backgroundImage: AssetImage("assets/male_avatar.jpg"),
            radius: 25,
          ),
        ),
      ),
    );
  }

}