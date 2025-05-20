import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logistics_app/helper/app_assets.dart';
import 'package:logistics_app/helper/app_colors.dart';
import 'package:logistics_app/main.dart';
import 'package:logistics_app/services/db_storage.dart';

class DeleteUserAccount extends StatefulWidget {
  const DeleteUserAccount({Key? key}) : super(key: key);

  @override
  State<DeleteUserAccount> createState() => _DeleteUserAccountState();
}

class _DeleteUserAccountState extends State<DeleteUserAccount> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController reasonController = TextEditingController();
  String? selectedValue;
  List<String> reasonList = [
    'Find a Better Alternative',
    'Need a Break',
    'Do not find useful anymore',
    'Other',
  ];

  bool otherReasonBox = false;
  final _formKey = GlobalKey<FormState>();

  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: AppBar(
            backgroundColor: AppColors.themeColor,
            iconTheme: IconThemeData(color: Colors.white),
            centerTitle: true,
            title: Text('Account',
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600)),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Image.asset(AppAssets.appLogo, width: size.width * 0.6),
                    SizedBox(height: 20),
                    Text(
                      'Delete your account ',
                      style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 20,fontWeight: FontWeight.w600),
                    ),
                    Text(
                      "Help us improve our app, Explain the reason why you want to delete your account",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(
                      height: 20
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        isExpanded: true,
                        hint: Text(
                          '--Select--',
                          style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                        items: reasonList
                            .map((String item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: GoogleFonts.poppins(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        value: selectedValue,
                        onChanged: (String? value) {
                          selectedValue = value;
                          if (selectedValue == "Other") {
                            otherReasonBox = true;
                          } else {
                            otherReasonBox = false;
                          }
                          setState(() {});
                        },
                        buttonStyleData: ButtonStyleData(
                          height: 50,
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                              ),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5))),
                        ),
                        iconStyleData: const IconStyleData(
                          icon: Icon(
                            Icons.arrow_drop_down_sharp,
                          ),
                          iconSize: 25,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white,
                          ),
                          offset: const Offset(0, -5),
                          scrollbarTheme: ScrollbarThemeData(
                            radius: const Radius.circular(5),
                            thickness: MaterialStateProperty.all<double>(6),
                            thumbVisibility:
                                MaterialStateProperty.all<bool>(true),
                          ),
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          height: 40,
                          padding: EdgeInsets.only(left: 14, right: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onTap: () {
                      logOutPermissionDialog(context);
                    },
                    child: Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.themeColor),
                      child: Center(
                        child: Text(
                          'Submit',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ));
  }
}

/// LOG OUT DIALOG
void logOutPermissionDialog(BuildContext context) => showDialog(
      context: context,
      builder: (_ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Are you sure you want to delete your account',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text('NO',
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.w500))),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () async {
                        EasyLoading.show(status: "Please wait...");
                        try {
                          DbStorage dbStorage = DbStorage();
                          await Future.delayed(Duration(seconds: 2));
                          // Now clear all data
                          await dbStorage.clearAllData(context);
                        } catch (e) {
                          EasyLoading.dismiss();
                        } finally {
                          EasyLoading.dismiss();
                        }
                      },
                      child: const Text(
                        'YES',
                        style: TextStyle(
                            color: Colors.deepPurpleAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
