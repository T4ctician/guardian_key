import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:guardian_key/src/constants/sizes.dart';
import 'package:guardian_key/src/constants/colors.dart';
import 'package:guardian_key/src/constants/text_strings.dart';
import 'package:guardian_key/src/features/authentication/models/user_model.dart';
import 'package:guardian_key/src/features/authentication/screens/profile/update_profile_screen.dart';
import 'package:guardian_key/src/features/authentication/screens/profile/widgets/image_with_icon.dart';
import 'package:guardian_key/src/features/authentication/screens/profile/widgets/profile_menu.dart';
import 'package:guardian_key/src/features/authentication/screens/profile/widgets/toggle_menu_widget.dart';
import 'package:guardian_key/src/features/authentication/controllers/profile_controller.dart';


import 'package:guardian_key/src/repository/authentication_repository.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  _fetchUserData() async {
    final user = await ProfileController.instance.getUserData(); // Assuming you fetch user data from ProfileController
    setState(() {
      _currentUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => Get.back(), icon: const Icon(LineAwesomeIcons.angle_left)),
        title: Text(tProfile, style: Theme.of(context).textTheme.headlineMedium),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(tDefaultSize),
          child: Column(
            children: [
              const ImageWithIcon(),
              const SizedBox(height: 10),
              Text(
                _currentUser == null ? "Loading..." : "${_currentUser!.firstName} ${_currentUser!.lastName}",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                _currentUser?.email ?? "Loading...",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () => Get.to(() => UpdateProfileScreen()),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: tPrimaryColor, side: BorderSide.none, shape: const StadiumBorder()),
                  child: const Text(tEditProfile, style: TextStyle(color: tSecondaryColor)),
                ),
              ),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 10),
              ToggleMenuWidget(
                title: "Biometric Authentication",
                icon: LineAwesomeIcons.user_check,
                initialValue: false,
                onChanged: (value) {},
              ),
              ToggleMenuWidget(
                title: "Auto fill pass",
                icon: LineAwesomeIcons.wallet,
                initialValue: false,
                onChanged: (value) {},
              ),
              const Divider(),
              const SizedBox(height: 10),
              ProfileMenuWidget(title: "Information", icon: LineAwesomeIcons.info, onPress: () {}),
              ProfileMenuWidget(
                  title: "Logout",
                  icon: LineAwesomeIcons.alternate_sign_out,
                  textColor: Colors.red,
                  endIcon: false,
                  onPress: () {
                    Get.defaultDialog(
                      title: "LOGOUT",
                      titleStyle: const TextStyle(fontSize: 20),
                      content: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                        child: Text("Are you sure, you want to Logout?"),
                      ),
                      confirm: ElevatedButton(
                        onPressed: () => AuthenticationRepository.instance.logout(),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, side: BorderSide.none),
                        child: const Text("Yes"),
                      ),
                      cancel: OutlinedButton(onPressed: () => Get.back(), child: const Text("No")),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

