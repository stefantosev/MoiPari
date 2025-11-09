import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/navigation_provider.dart';


class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [Color(0xFFFFDEE9), Color(0xFFFCC2FF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
          )
        ),
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset("assets/images/MoiPari.png"),
                        SizedBox(height: 30),
                        Text(
                          "Manage your money and set limits",
                           style: TextStyle(
                             fontSize: 20,
                             color: Colors.black,
                             fontWeight: FontWeight.bold
                           ),
                        ),
                        SizedBox(height: 60),
                        SizedBox(
                          child: ElevatedButton(
                              onPressed: () {
                                ref.read(navigationIndexProvider.notifier).state = 0;
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurpleAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)
                                ),
                              ),
                              child: Text(
                                "Get started",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold
                                ),
                              )
                          ),
                        )
                      ],
                    ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
