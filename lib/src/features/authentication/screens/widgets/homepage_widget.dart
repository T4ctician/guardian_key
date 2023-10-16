import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:guardian_key/src/constants/CategoryContainer.dart';
import 'package:guardian_key/src/constants/constants.dart';
import 'package:guardian_key/src/constants/text_strings.dart';
import 'package:guardian_key/src/features/authentication/models/user_model.dart';
import 'package:guardian_key/src/features/authentication/models/credential_model.dart';
import 'package:guardian_key/src/features/authentication/controllers/profile_controller.dart';
import 'package:guardian_key/src/features/authentication/screens/profile/profile_screen.dart';
import 'package:guardian_key/src/features/authentication/screens/widgets/homepagefunction/note_section.dart';
import 'package:guardian_key/src/services/login_service.dart'; 
import 'package:guardian_key/src/features/authentication/screens/widgets/homepagefunction/credential_section.dart';



class HomePageWidget extends StatefulWidget {
  const HomePageWidget({Key? key}) : super(key: key);

  @override
  HomePageWidgetState createState() => HomePageWidgetState();
}

class HomePageWidgetState extends State<HomePageWidget> {
  List<CredentialModel> displayedPasswords = [];
  final weakPasswordAlertNotifier = ValueNotifier<bool>(false);

  UserModel? _currentUser;
  final loginService = LoginService();
  String? currentSection;

  void _showCredentialModal() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
    ),
    builder: (BuildContext bc) {
      return CredentialsSection(); 
    }
  ).then((value) {
  });
}

  void _showNoteModal() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
    ),
    builder: (BuildContext bc) {
      return NotesSection(); 
    }
  ).then((value) {
  });
}

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

    _fetchUserData() async {
    final controller = ProfileController.instance;
    final user = await controller.getUserData();
    final passwordData = await loginService.fetchPasswordData();

    setState(() {
      _currentUser = user;
      displayedPasswords = passwordData;  // Update the displayedPasswords list with the fetched data
    });
  }

  Future<void> _refreshData() async {
  try {
    await _fetchUserData();  // This fetches and updates your data
    setState(() {}); // This ensures the UI is refreshed
  } catch (error) {
    // Handle any errors here
    print('Error refreshing data: $error');
  }
}


    @override
  void dispose() {
    weakPasswordAlertNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 0),
            child: Column(
              children: [
                profilePic(screenHeight),
                const SizedBox(height: 8),
                HeadingText(tCategory),
                const SizedBox(height: 10),
                CategoryBoxes(),
                const SizedBox(height: 15),
                RefreshIndicator(
                  onRefresh: _refreshData,
                  child: getCurrentSection(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget HeadingText(String text) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 10, 0, 0),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget CategoryBoxes() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              SizedBox(
                height: 150,
                width: 400,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      currentSection = "Credential";
                      _showCredentialModal();
                    });
                  },
                  child: CategoryBox(
                    outerColor: Constants.lightBlue,
                    innerColor: Constants.darkBlue,
                    logoAsset: "assets/codesandbox.svg",
                  ),
                ),
              ),
              const SizedBox(height: 5.0),  // Reduced height for spacing
              const Text(
                "Credential",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              SizedBox(
                height: 150,
                width: 400,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      currentSection = "Notes";
                      _showNoteModal();
                    });
                  },
                  child: CategoryBox(
                  outerColor: Constants.lightGreen,
                  innerColor: Constants.darkGreen,
                  logoAsset: "assets/compass.svg",
                ),
                ),
              ),
              const SizedBox(height: 5.0),
              const Text(
                "Note",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              SizedBox(
                height: 150,
                width: 400,
                child: CategoryBox(
                  outerColor: Constants.lightRed,
                  innerColor: Constants.darkRed,
                  logoAsset: "assets/credit-card.svg",
                ),
              ),
              const SizedBox(height: 5.0),
              const Text(
                "Credit Card",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget circleAvatarRound() {
    return const CircleAvatar(
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

  Widget profilePic(double screenHeight) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 35, 20.0, 5),
        child: Row(
          children: [
            circleAvatarRound(),
            const SizedBox(width: 8.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentUser == null
                        ? "Loading..."
                        : "Hello, ${_currentUser!.firstName} ${_currentUser!.lastName}",
                    style: TextStyle(
                      color: Color.fromARGB(255, 22, 22, 22),
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "Good ${greeting()}",
                    style: TextStyle(
                      color: Color.fromARGB(255, 39, 39, 39),
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.refresh, color: Colors.black),
                onPressed: _refreshData,
              ),
            ),
          ],
        ),
      ),
    );
  }

String greeting() {
  var hour = DateTime.now().hour;
  if (hour < 12) {
    return 'Morning';
  }
  if (hour < 17) {
    return 'Afternoon';
  }
  return 'Evening';
}

Widget getCurrentSection() {
  switch (currentSection) {
    case "Credential":
      return CredentialsSection();
    case "Note":
      return NotesSection(); 
    case "Credit Card":
      // Return the Credit Card content widget when you create it
      return Text("Credit Card Section"); // placeholder
    default:
      return Container(); // default empty container or any default view
  }
}


}