/*import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_key/src/features/authentication/screens/widgets/homepage_widget.dart';
import 'package:mockito/mockito.dart';
import 'package:guardian_key/src/constants/CategoryContainer.dart';


void main() {
  group('HomePageWidget Tests', () {
    // You can initialize any mock objects here if necessary.

    testWidgets('HomePageWidget shows the correct initial UI elements', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(MaterialApp(home: HomePageWidget()));

      // Verify that the correct UI elements are in place.
      expect(find.text('Loading...'), findsOneWidget); // If the user data is not loaded yet
      expect(find.byType(CircleAvatar), findsWidgets); // If you have a CircleAvatar in your widget
      // ... add more `expect` statements to test various UI components
    });

    testWidgets('Tapping on a category opens the corresponding modal', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(MaterialApp(home: HomePageWidget()));

      // Tap on the CategoryBox for Credentials.
      await tester.tap(find.byType(CategoryBox).first);
      await tester.pump(); // Rebuild the widget after the state has changed.

      // Verify that showModalBottomSheet is called and CredentialsSection is shown.
      // You would need to mock the showModalBottomSheet function to test this properly.
      // ...
    });

    // ... more tests
  });
}
*/