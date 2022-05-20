import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:measurement_app/utils/auth_service.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';

class MobileAuthPage extends StatefulWidget {
  const MobileAuthPage({Key? key}) : super(key: key);

  @override
  State<MobileAuthPage> createState() => _MobileAuthPageState();
}

class _MobileAuthPageState extends State<MobileAuthPage> {
  int start = 30;
  bool wait = false;
  String buttonName = "Send";
  TextEditingController phoneController = TextEditingController();
  AuthClass authClass = AuthClass();
  String verificationIdFinal = "";
  String smsCode = "";

  var phoneNumber=PhoneNumber(isoCode: 'US');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white70,
        foregroundColor: Colors.black,
        title: const Text(
          "SignUp",
          style: TextStyle(color: Colors.black, fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 150,
              ),
              phoneField(),
              const SizedBox(
                height: 20,
              ),
              Container(
                width: MediaQuery.of(context).size.width - 30,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: Colors.grey,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                    const Text(
                      "Enter 6 digit OTP",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: Colors.grey,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              otpField(),
              const SizedBox(
                height: 40,
              ),
              ritchTextField(),
              const SizedBox(
                height: 30,
              ),
              buttonField(),
            ],
          ),
        ),
      ),
    );
  }

  void startTimer() {
    const onsec = Duration(seconds: 1);
    Timer _timer = Timer.periodic(onsec, (timer) {
      if (start == 0) {
        setState(() {
          timer.cancel();
          wait = false;
        });
      } else {
        setState(() {
          start--;
        });
      }
    });
  }

  Widget otpField() {
    return Container(
      child: OTPTextField(
        length: 6,
        width: MediaQuery.of(context).size.width - 34,
        fieldWidth: 58,
        otpFieldStyle: OtpFieldStyle(
          backgroundColor: const Color(0xffe3e3e3),
        ),
        style: const TextStyle(fontSize: 17),
        textFieldAlignment: MainAxisAlignment.spaceAround,
        fieldStyle: FieldStyle.underline,
        onCompleted: (pin) {
          print("Completed: " + pin);
          setState(() {
            smsCode = pin;
          });
        },
      ),
    );
  }

  Widget ritchTextField() {
    return RichText(
        text: TextSpan(children: [
      const TextSpan(
        text: "Send OTP again in",
        style: TextStyle(fontSize: 16, color: Colors.black54),
      ),
      TextSpan(
        text: '00: $start',
        style: const TextStyle(fontSize: 16, color: Colors.pinkAccent),
      ),
      const TextSpan(
        text: "sec",
        style: TextStyle(fontSize: 16, color: Colors.black54),
      ),
    ]));
  }

  Widget buttonField() {
    return InkWell(
      onTap: () {
        authClass.signInwithPhoneNumber(verificationIdFinal, smsCode, context);
      },
      child: Container(
        height: 60,
        width: MediaQuery.of(context).size.width - 60,
        decoration: BoxDecoration(
            color: const Color(0xffff9601),
            borderRadius: BorderRadius.circular(16)),
        child: const Center(
          child: Text(
            "Lets Go",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget phoneField() {
    return Container(
        width: MediaQuery.of(context).size.width - 40,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xffe1e1e1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: InternationalPhoneNumberInput(
          validator: (String? value) {
            if (value != null && value.isEmpty == true) {
              return 'Please enter your phone number';
            }
            return null;
          },
          selectorConfig: SelectorConfig(
            selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
          ),
          inputDecoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Phone Number",
              hintStyle: const TextStyle(
                color: Colors.black,
                fontSize: 17,
              ),
              contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              suffixIcon: InkWell(
                onTap: wait
                    ? null
                    : () async {
                  if(phoneController.text.trim().isEmpty||phoneController.text.trim().length<10) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text("Please enter your phone number"),
                      backgroundColor: Colors.red,
                    ));
                    return;
                  }
                  print("Submitting: " + phoneController.text);
                  setState(() {
                    start = 30;
                    wait = true;
                    buttonName = "Resend";
                  });
                  await authClass.verifyPhoneNumber(
                      "${phoneController.text}", context, setData);
                },
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 17),
                  child: Text(
                    buttonName,
                    style: TextStyle(
                        color: wait ? Colors.grey : Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              )
          ),
          initialValue: phoneNumber,
          inputBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
                color: Color(0xffe1e1e1), width: 5, style: BorderStyle.none),
          ),
          onInputChanged: (PhoneNumber value) {
            print("OnInputChanged:"+value.phoneNumber!);
            setState(() {
              phoneController.text = value.phoneNumber!;
              // phoneNumber = value;
            });
          },
        )
        );
  }

  void setData(String verificationId) {
    setState(() {
      verificationIdFinal = verificationId;
    });
    startTimer();
  }
}
