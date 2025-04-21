// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:segma/utils/providers.dart';

// class SettingsScreen extends StatelessWidget {
//   const SettingsScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Consumer<ThemeProvider>(
//           builder: (context, themeProvider, child) {
//             bool isDarkMode = themeProvider.themeMode == ThemeMode.dark;
//             return Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   isDarkMode ? 'Dark Mode' : 'Light Mode',
//                   style: Theme.of(context).textTheme.bodyLarge,
//                 ),
//                 Switch(
//                   value: isDarkMode,
//                   onChanged: (value) {
//                     themeProvider.toggleTheme(value);
//                   },
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }