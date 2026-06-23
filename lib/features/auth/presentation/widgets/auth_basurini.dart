// import 'package:flutter/material.dart';
// import 'package:treasureflow/shared/components/basurini/basurini_avatar.dart';
// import 'package:treasureflow/shared/components/basurini/speech_bubble.dart';
// import 'package:treasureflow/shared/components/basurini/basurini_types.dart';

// class AuthBasurini extends StatelessWidget {
//   final BasuriniMood mood;
//   final String speechText;
//   final String? highlightText;
//   final BasuriniBubbleType bubbleType;

//   const AuthBasurini({
//     super.key,
//     this.mood = BasuriniMood.welcome,
//     required this.speechText,
//     this.highlightText,
//     this.bubbleType = BasuriniBubbleType.neutral,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       clipBehavior: Clip.none,
//       alignment: Alignment.center,
//       children: [
//         BasuriniAvatar(mood: mood, height: 160.0),

//         Positioned(
//           top: -20,
//           right: -60,
//           child: SpeechBubble(
//             text: speechText,
//             highlightText: highlightText,
//             type: bubbleType,
//             tailPosition: BubbleTailPosition.bottomLeft,
//           ),
//         ),
//       ],
//     );
//   }
// }
