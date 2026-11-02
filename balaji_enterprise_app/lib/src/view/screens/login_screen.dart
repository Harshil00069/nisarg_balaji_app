import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/constant/database_helper.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/view/models/company_model.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/view/helper/api_service.dart';
import 'package:flutter_face_detection_balaji_enterprise/utils/app_colors.dart';
import 'package:flutter_face_detection_balaji_enterprise/utils/app_images.dart';
import 'package:flutter_face_detection_balaji_enterprise/utils/app_routes.dart';
import 'package:flutter_face_detection_balaji_enterprise/utils/app_strings.dart';
import 'package:flutter_face_detection_balaji_enterprise/widgets/primary_button_widget.dart';
import 'package:flutter_face_detection_balaji_enterprise/widgets/primary_text_input_widget.dart';
import 'package:flutter_face_detection_balaji_enterprise/widgets/primary_title_text_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool loading = false;
  bool obscurePassword = true;
  List<CompanyModel> companyList = [];
  CompanyModel? selectedCompany;

  @override
  void initState() {
    super.initState();
    fetchCompanies();
  }

  Future<void> fetchCompanies() async {
    List<CompanyModel> companies = await ApiService().getAllCompanyApi();
    setState(() {
      companyList = companies;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Center(
                child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 16),
                                Image.asset(AppImages.imgLogo,
                                    fit: BoxFit.contain, height: 100),
                                const SizedBox(height: 16),
                                const PrimaryTitleTextWidget(
                                    title: AppStrings.strCapsLogin,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    textAlign: TextAlign.center),
                                const SizedBox(height: 16),
                                companyList.isEmpty
                                    ? const Center(
                                        child: CircularProgressIndicator())
                                    : DropdownButtonFormField<CompanyModel>(
                                        initialValue: selectedCompany,
                                        style: TextStyle(
                                            color: AppColors.primary
                                                .withValues(alpha: 0.7),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500),
                                        isExpanded: true,
                                        isDense: true,
                                        alignment: Alignment.center,
                                        elevation: 16,
                                        // dropdownColor: Colors.red,
                                        borderRadius: BorderRadius.circular(12),
                                        decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 14,
                                                    horizontal: 16),
                                            labelText: 'Select Company',
                                            labelStyle: TextStyle(
                                                color: AppColors.primary
                                                    .withValues(alpha: 0.7),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500),
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: const BorderSide(
                                                    color: AppColors.primary,
                                                    width: 1.5)),
                                            focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: const BorderSide(
                                                    color: AppColors.primary,
                                                    width: 1.5)),
                                            filled: true,
                                            fillColor: AppColors.primary
                                                .withValues(alpha: 0.05)),
                                        items:
                                            companyList.map((CompanyModel e) {
                                          return DropdownMenuItem<CompanyModel>(
                                              value: e,
                                              child: Text(e.companyName ?? '',
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: AppColors.text,
                                                      fontWeight:
                                                          FontWeight.w500)));
                                        }).toList(),
                                        validator: (value) {
                                          if (value == null) {
                                            return 'Please select a company';
                                          }
                                          return null;
                                        },
                                        onChanged: (CompanyModel? value) {
                                          setState(() {
                                            selectedCompany = value;
                                          });
                                        },
                                      ),
                                const SizedBox(height: 16),
                                const PrimaryTitleTextWidget(
                                    title: AppStrings.strEmail),
                                const SizedBox(height: 4),
                                PrimaryTextInputWidget(
                                  textController: emailController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter username';
                                    }
                                    // if (!AppConstants.emailRegEx
                                    //     .hasMatch(value)) {
                                    //   return 'Please enter a valid email address';
                                    // }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 8),
                                const PrimaryTitleTextWidget(
                                    title: AppStrings.strPassword),
                                const SizedBox(height: 4),
                                PrimaryTextInputWidget(
                                    textController: passwordController,
                                    obscureText: obscurePassword,
                                    textInputAction: TextInputAction.done,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your password';
                                      }
                                      if (value.length <= 4) {
                                        return 'Password must be more than 4 characters';
                                      }
                                      return null;
                                    },
                                    suffixIcon: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            obscurePassword = !obscurePassword;
                                          });
                                        },
                                        child: Icon(
                                          obscurePassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: AppColors.grey,
                                        ))),
                                const SizedBox(height: 8),
                                loading
                                    ? const Center(
                                        child: CircularProgressIndicator())
                                    : Padding(
                                        padding: const EdgeInsets.only(
                                            top: 16, bottom: 24),
                                        child: PrimaryButtonWidget(
                                            onTap: onLoginTap,
                                            title: AppStrings.strLogin)),
                              ],
                            )))))));
  }

  Future<void> onLoginTap() async {
    if (formKey.currentState?.validate() ?? false) {
      setState(() {
        loading = true;
      });
      final result = await ApiService().getLoginApi(selectedCompany?.companyId,
          emailController.text, passwordController.text);

      setState(() {
        loading = false;
      });
      if (result?.status == 0) {
        final databaseHelper = DatabaseHelper();
        if (result != null && result.data != null) {
          await databaseHelper.createEmpInfoTable(
            userId: result.data!.userId?.toInt() ?? 0,
            empId: result.data!.userId?.toInt() ?? 0,
            companyId: result.data!.companyId?.toInt() ?? 0,
            baseUrl: "",
            columnToken: result.data!.token??""
          );
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('loginResponse', jsonEncode(result?.toJson()));
        await prefs.setBool('isLogin', true);
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.routeHomeScreen,  (Route<dynamic> route) => false);
      } else {
        Fluttertoast.showToast(msg: result?.message ?? '');
      }
    }
  }
}
