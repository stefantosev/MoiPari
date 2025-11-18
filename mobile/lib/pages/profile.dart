import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/auth_provider.dart';
import 'package:mobile/service/auth_service.dart';

class ProfilePage extends ConsumerWidget {
  ProfilePage({super.key});
  var userEmail = AuthService.getUserEmail();

  //TODO TOSO: UPDATES THE FRONTEND AND THE ANALYTICS PAGE
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Stack(
            children: [FutureBuilder(
                future: userEmail, builder: (context, snapshot){
              return Text(
                  "Email: ${snapshot.data}"
              );
            }
            ),
              TextButton(
                  onPressed: () {
                    ref.read(authStateProvider.notifier).logout();
                  },
                  child: Text("Logout"))
            ]
        ),
      )
    );
  }


}


