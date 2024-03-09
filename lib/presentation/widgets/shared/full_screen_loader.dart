import 'package:flutter/material.dart';

class FullScreenLoader extends StatelessWidget {
  FullScreenLoader({super.key});

  final message = <String>[
    'Cocinando palomitas de maíz',
    'Cargando películas',
    'Cargando populares',
    'Esperando...',
    'Ya casi estamos listos para comenzar',
  ];

  Stream<String> getLoadingMessage() {
    return Stream.periodic(const Duration(milliseconds: 1500), (step) {
      return message[step];
    }).take(message.length);
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(height: 40),
        CircularProgressIndicator(
          strokeWidth: 2,
        )
      ]),
    );
  }
}

//     return Center(
//         child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         const SizedBox(height: 30),
//         const CircularProgressIndicator(strokeWidth: 2),
//         const SizedBox(height: 15),
//         StreamBuilder(
//           stream: getLoadingMessage(),
//           builder: (context, snapshot) {
//             if (!snapshot.hasData) {
//               return Text('Cargando...', style: textStyle.labelSmall);
//             }
//             return Text(snapshot.data!, style: textStyle.labelSmall);
//           },
//         )
//       ],
//     ));
//   }
// }
