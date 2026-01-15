import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:project_uas/pages/main_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeUI();
  }
}

class HomeUI extends StatefulWidget {
  const HomeUI({super.key});

  @override
  State<HomeUI> createState() => _HomeUIState();
}

class _HomeUIState extends State<HomeUI> {
  // dummy account
  final String validEmail = "syauqi@gmail.com";
  final String validPassword = "12345";

  FocusNode emailFocusNode = FocusNode();
  TextEditingController emailController = TextEditingController();

  FocusNode passwordFocusNode = FocusNode();
  TextEditingController passwordController = TextEditingController();

  StateMachineController? controller;

  SMIBool? lookOnEmail;
  SMINumber? followOnEmail;
  SMIBool? lookOnPassword;
  SMIBool? peekOnPassword;
  SMITrigger? triggerSuccess;
  SMITrigger? triggerFail;

  @override
  void initState() {
    emailFocusNode.addListener(() {
      lookOnEmail?.change(emailFocusNode.hasFocus);
    });

    passwordFocusNode.addListener(() {
      lookOnPassword?.change(passwordFocusNode.hasFocus);
    });
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 153, 18, 92),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 86),
            Text(
              "MoneyTrack",
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: Colors.white),
            ),
            SizedBox(height: 80),

            /// RIVE
            SizedBox(
              height: 300,
              width: 300,
              child: RiveAnimation.asset(
                "assets/animation/auth-teddy.riv",
                fit: BoxFit.fitHeight,
                onInit: (artboard) {
                  controller = StateMachineController.fromArtboard(
                    artboard,
                    "Login Machine",
                  );

                  if (controller == null) return;
                  artboard.addController(controller!);

                  lookOnEmail = controller?.getBoolInput("isFocus");
                  followOnEmail = controller?.getNumberInput("numLook");
                  lookOnPassword = controller?.getBoolInput("isPrivateField");
                  peekOnPassword = controller?.getBoolInput(
                    "isPrivateFieldShow",
                  );
                  triggerSuccess = controller?.getTriggerInput(
                    "successTrigger",
                  );
                  triggerFail = controller?.getTriggerInput("failTrigger");
                },
              ),
            ),

            /// FORM
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  TextFormField(
                    controller: emailController,
                    focusNode: emailFocusNode,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      followOnEmail?.change(value.length * 1.5);
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: passwordController,
                    focusNode: passwordFocusNode,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                    ),
                    onTap: () {
                      peekOnPassword?.change(true);
                    },
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 15, 9, 51),
                      ),

                      onPressed: onClickLogin,
                      child: Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.white30,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onClickLogin() async {
    emailFocusNode.unfocus();
    passwordFocusNode.unfocus();

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    Navigator.pop(context);

    final valid =
        email.toLowerCase() == validEmail.toLowerCase() &&
        password == validPassword;

    if (valid) {
      //  trigger animasi sukses
      triggerSuccess?.fire();

      //  tunggu animasi selesai
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      //  pindah ke MainPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainPage()),
      );
    } else {
      triggerFail?.fire();
    }
  }
}
