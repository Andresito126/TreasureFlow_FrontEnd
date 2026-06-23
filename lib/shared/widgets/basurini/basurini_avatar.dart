// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'basurini_types.dart';

// class BasuriniAvatar extends StatelessWidget {
//   final BasuriniMood mood;
//   final double height;

//   const BasuriniAvatar({
//     super.key,
//     this.mood = BasuriniMood.welcome,
//     this.height = 160.0,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SvgPicture.asset(
//       mood.assetPath,
//       height: height,
//       placeholderBuilder: (context) => SizedBox(
//         height: height, 
//         width: height, 
//         child: const Placeholder(color: Colors.green), 
//       ),
//     );
//   }
// }