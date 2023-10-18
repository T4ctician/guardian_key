import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../constants/constants.dart';
import 'package:get/get.dart';
import 'package:guardian_key/src/features/authentication/models/random_password.dart';
import 'package:password_strength_checker/password_strength_checker.dart';
import 'package:guardian_key/src/features/authentication/models/credential_model.dart'; 
import 'package:guardian_key/src/features/authentication/controllers/addcredential_controller.dart';
import 'package:guardian_key/src/services/login_service.dart';
import 'package:guardian_key/src/features/authentication/screens/profile/passwordconfig.dart';



class AddModal extends StatefulWidget {
  final CredentialModel? passwordO;

  const AddModal({Key? key, this.passwordO}) : super(key: key);

  @override
  AddModalState createState() => AddModalState();
}

class AddModalState extends State<AddModal> {
  String? selectedWebsite;
  String? selectedLoginId;
  int? passwordLength;
  int? numUpperCase;
  int? numLowerCase;
  int? numSpecialChars;
  String? userId;
  final LoginService loginService = LoginService();
  TextEditingController websiteNameController = TextEditingController();
  TextEditingController userIDController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController(); // Create the password controller
  final weakPasswordAlertNotifier = ValueNotifier<bool>(false);
  final colorNotifier = ValueNotifier<Color>(Colors.orange);



  @override
  void initState() {
    super.initState();
    selectedWebsite = widget.passwordO?.websiteName;
    if (widget.passwordO != null) {
      selectedLoginId = widget.passwordO!.id;
      websiteNameController.text = widget.passwordO!.websiteName ?? '';
      userIDController.text = widget.passwordO!.userID ?? '';
      emailController.text = widget.passwordO!.email ?? '';
      passwordController.text = widget.passwordO!.password ?? '';
    }
    userId = FirebaseAuth.instance.currentUser?.uid;
    _fetchPasswordSettings();
  }

  Future<void> _fetchPasswordSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      passwordLength = (prefs.getDouble('${userId}_passwordLength') ?? 8.0).toInt();
      numUpperCase = (prefs.getDouble('${userId}_numUpperCase') ?? 1.0).toInt();
      numLowerCase = (prefs.getDouble('${userId}_numLowerCase') ?? 1.0).toInt();
      numSpecialChars = (prefs.getDouble('${userId}_numSpecialChars') ?? 1.0).toInt();
    });
  }

   @override
  void dispose() {
    passwordController.dispose(); 
    websiteNameController.dispose();
    userIDController.dispose();
    emailController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 10, 10, 10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: screenWidth * 0.4,
                height: 5,
                decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 156, 156, 156),
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            websiteContainer(context, loginService),
            Column(
              children: [
                formHeading("Website / Application Name"),
                formTextField("Enter Website/ Application Name", Icons.web, controller: websiteNameController),
                formHeading("Login ID"),
                formTextField("Enter Login ID", Icons.person, controller: userIDController),
                formHeading("E-mail"),
                formTextField("Enter Email", Icons.email, controller: emailController),
                formHeading("Password"),
                formTextField("Enter Password", Icons.lock_outline, controller: passwordController, showGenerateButton: true),
              ],
            ),
            const SizedBox(
              height: 50,
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    // Ok Done Button
                    SizedBox(
                      height: screenHeight * 0.065,
                      width: screenWidth * 1.0 * 0.8,
                      child: 
                      ElevatedButton(
                      onPressed: () async {
                        String websiteName = websiteNameController.text.trim();
                        String userId = userIDController.text.trim();
                        String email = emailController.text.trim();
                        String password = passwordController.text.trim();

                        if (websiteName.isEmpty) {
                          // Show a snackbar to the user
                          Get.snackbar(
                            'Error',
                            'Website/Application Name cannot be empty.',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        if (email.isEmpty) {
                          // Show a snackbar to the user
                          Get.snackbar(
                            'Error',
                            'Email cannot be empty.',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        if (password.isEmpty) {
                          // Show a snackbar to the user
                          Get.snackbar(
                            'Error',
                            'Password cannot be empty.',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }
                        
                        // Create a new CredentialModel instance with the data from text fields
                          CredentialModel login = CredentialModel(
                            id: widget.passwordO?.id, // Add this line
                            websiteName: websiteNameController.text.trim(),
                            userID: userIDController.text.trim(),
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                            );

                        // Check if login already exists
                          CredentialModel? existingLogin = await AddCredentialController.instance.getLoginByWebsiteName(login.websiteName);

                          if (existingLogin == null) {
                          // Call the addLogin method to save the login
                            AddCredentialController.instance.addLogin(login);
                            } else {
                            // Call the updateLogin method to update the existing login
                            AddCredentialController.instance.updateLogin(login);
                            }

                          // Close the modal
                          Navigator.pop(context);
                        },
                            child: const Text(
                                "Ok Done",
                                style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                        ),
                    ),
                // Red Circle Delete Button
                SizedBox(
                  height: screenHeight * 0.065,
                  width: screenHeight * 0.065,
                  child: ElevatedButton(
                    onPressed: () async {
                      bool? shouldDelete = await showConfirmationDialog(context);
                      if (shouldDelete == true) {
                        // Delete the login based on the unique identifier
                        AddCredentialController.instance.deleteLogin(selectedLoginId ?? ''); // using websiteName as a unique ID for now

                        // Close the modal
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }

final passNotifier = ValueNotifier<PasswordStrength?>(null);

Widget formTextField(String hintText, IconData icon, {TextEditingController? controller, bool showGenerateButton = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextFormField(
                controller: controller,
                onChanged: (value) {
                  if (hintText == "Enter Password") {
                    final strength = PasswordStrength.calculate(text: value);
                    passNotifier.value = strength;
                    weakPasswordAlertNotifier.value = strength == PasswordStrength.alreadyExposed || strength == PasswordStrength.weak;
                  }
                },
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      20, 5, 5, 5
                    ),
                    child: Icon(
                      icon,
                      color: Constants.searchGrey,
                    ),
                  ),
                  filled: true,
                  contentPadding: const EdgeInsets.all(16),
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: Constants.searchGrey, fontWeight: FontWeight.w500
                  ),
                  fillColor: const Color.fromARGB(247, 232, 235, 237),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                    borderRadius: BorderRadius.circular(20)
                  ),
                ),
                style: const TextStyle(),
              ),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: weakPasswordAlertNotifier,
            builder: (context, isWeak, child) {
              if (hintText == "Enter Password" && isWeak) { // Add the hintText check here
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(seconds: 1),
                  onEnd: () {
                    colorNotifier.value = colorNotifier.value == Colors.orange ? Colors.red : Colors.orange;
                  },
                  builder: (context, double opacity, child) {
                    return ValueListenableBuilder<Color>(
                      valueListenable: colorNotifier,
                      builder: (context, color, _) {
                        return Opacity(
                          opacity: opacity,
                          child: Icon(Icons.warning, color: color),
                        );
                      },
                    );
                  },
                );
              } else {
                return Container();
              }
            },
          ),


        ],
      ),
      if (showGenerateButton) Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0, top: 5.0),
            child: InkWell(
                onTap: () async {
                  // The 'result' will contain the value passed back from Navigator.pop in PasswordConfigScreen
                  bool? result = await Get.to(() => const PasswordConfigScreen());
                  
                  // If 'result' is true, the settings were saved, so you can reload them.
                  if (result == true) {
                    _fetchPasswordSettings();
                  }
                },
              child: Container(
                padding: const EdgeInsets.only(left: 10.0),  // Add padding here
                child: const Text('Password \nConfiguration', 
                            style: TextStyle(color: Colors.blue)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10.0, top: 5.0),
            child: InkWell(
              onTap: () async {
                String generatedPassword = await generatePassword(
                  length: passwordLength!, 
                  numUpperCase: numUpperCase!, 
                  numLowerCase: numLowerCase!, 
                  numSpecialChars: numSpecialChars!
                );
                setState(() {  // Add setState to force a rebuild
                  passwordController.text = generatedPassword;
                  final strength = PasswordStrength.calculate(text: generatedPassword);
                  passNotifier.value = strength;
                  weakPasswordAlertNotifier.value = strength == PasswordStrength.alreadyExposed || strength == PasswordStrength.weak;
                });
              },
              child: const Text('Generate \nPassword', style: TextStyle(color: Colors.blue)),
            ),
          ),
        ],
      ),

      if (hintText == "Enter Password") Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: PasswordStrengthChecker(strength: passNotifier),
      ),
    ],
  );
}



  Widget formHeading(String text) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 10, 10, 10),
        child: Text(
          text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }

Widget websiteContainer(BuildContext context, LoginService loginService) {
  double screenHeight = MediaQuery.of(context).size.height;
  double screenWidth = MediaQuery.of(context).size.width;
  return Row(
    children: [
      GestureDetector(
        onTap: () {
          showAddModal(context);
        },
        child: Container(
          height: 55,
          width: 120,
          decoration: BoxDecoration(
            color: Constants.logoBackground,
            borderRadius: BorderRadius.circular(20)),
          child: FractionallySizedBox(
            heightFactor: 0.5,
            widthFactor: 0.5,
            child: Container(
              child: const Row(
                children: [
                  Icon(Icons.add),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    "Add",
                    style: TextStyle(fontSize: 14),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            height: 60,
            width: screenWidth * 0.6,
            child: FutureBuilder<List<String>>(
              // Replace Constants.websiteList with a call to LoginService method
              future: loginService.fetchWebsiteList(), // Use fetchWebsiteList from loginService
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Loading indicator while fetching data
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  // Handle error
                  return Text('Error: ${snapshot.error}');
                } else {
                  // Data is available, build the website blocks
                  List<String> websiteList = snapshot.data ?? [];
                  return ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: websiteList.length,
                    itemBuilder: (context, index) =>
                        websiteBlock(websiteList[index], context),
                  );
                }
              },
            ),
          ),
        ),
      ),
    ],
  );
}

void showAddModal(BuildContext context, {CredentialModel? passwordO}) {
  Navigator.of(context).pop();
  showModalBottomSheet(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
    ),
    isScrollControlled: true,
    context: context,
    builder: (BuildContext bc) {
      return Wrap(children: <Widget>[
        Container(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25.0),
                topRight: Radius.circular(25.0),
              ),
            ),
            child: AddModal(passwordO: passwordO),
          ),
        )
      ]);
    },
  );
}


  Widget websiteBlock(String websiteString, BuildContext context) {
    return FutureBuilder<CredentialModel?>(
      // Replace Constants.passwordData with a call to LoginService method to get the selected password
      future: loginService.getPasswordByWebsiteName(websiteString), // Adjust the method name according to your LoginService
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        // Loading indicator while fetching data
        return const CircularProgressIndicator();
      } else if (snapshot.hasError) {
        // Handle error
        return Text('Error: ${snapshot.error}');
      } else {
        final isSelected = websiteString == selectedWebsite;
        final selectedPassword = snapshot.data;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedWebsite = selectedPassword?.websiteName ?? 'DefaultWebsiteName';
            });

            if (selectedPassword != null) {
              showAddModal(context, passwordO: selectedPassword);
            }
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6.0, 3, 6, 3),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 200),
              height: 50,
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Constants.logoBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  websiteString,
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    },
  );
}


  Future<bool?> showConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Confirmation'),
          content: const Text('Are you sure you want to delete the logins?'),
          actions: <Widget>[
            TextButton(
              child: const Row(
                children: [
                  Icon(Icons.check, color: Colors.green),
                  Text('Yes', style: TextStyle(color: Colors.green)),
                ],
              ),
              onPressed: () {
                Navigator.of(context).pop(true);  // Return true when user taps 'Yes'
              },
            ),
            TextButton(
              child: const Row(
                children: [
                  Icon(Icons.close, color: Colors.red),
                  Text('No', style: TextStyle(color: Colors.red)),
                ],
              ),
              onPressed: () {
                Navigator.of(context).pop(false);  // Return false when user taps 'No'
              },
            ),
          ],
        );
      },
    );
}
  
}
