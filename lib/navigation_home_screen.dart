import 'package:esaydroid/best_flutter_ui_templates/app_theme.dart';
import 'package:esaydroid/setting_screen.dart';
import 'package:esaydroid/custom_drawer/drawer_user_controller.dart';
import 'package:esaydroid/custom_drawer/home_drawer.dart';
import 'package:esaydroid/home_screen.dart';
import 'package:flutter/material.dart';

class NavigationHomeScreen extends StatefulWidget {
  @override
  _NavigationHomeScreenState createState() => _NavigationHomeScreenState();
}

class _NavigationHomeScreenState extends State<NavigationHomeScreen> {
  Widget? screenView;
  DrawerIndex? drawerIndex;

  @override
  void initState() {
    drawerIndex = DrawerIndex.HOME;
    screenView = const MyHomePage();
    super.initState();
  }
  double calculateDrawerWidth(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 900) {
      return screenWidth * 0.25; // 화면 너비의 18%
    } else if (screenWidth >= 600) {
      return screenWidth * 0.35; // 화면 너비의 35%
    } else {
      return screenWidth * 0.75; // 기본값은 화면 너비의 75%
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.white,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          backgroundColor: AppTheme.nearlyWhite,
          body: DrawerUserController(
            screenIndex: drawerIndex,
            drawerWidth: calculateDrawerWidth(context),
            onDrawerCall: (DrawerIndex drawerIndexdata) {
              changeIndex(drawerIndexdata);
              //callback from drawer for replace screen as user need with passing DrawerIndex(Enum index)
            },
            screenView: screenView,
            //we replace screen view as we need on navigate starting screens like MyHomePage, HelpScreen, FeedbackScreen, etc...
          ),
        ),
      ),
    );
  }

  void changeIndex(DrawerIndex drawerIndexdata) {
    if (drawerIndex != drawerIndexdata) {
      drawerIndex = drawerIndexdata;
      switch (drawerIndex) {
        case DrawerIndex.HOME:
          setState(() {
            screenView = const MyHomePage();
          });
          break;
        case DrawerIndex.Setting:
          setState(() {
            screenView = SettingScreen();
          });
          break;
        // case DrawerIndex.Help:
        //   setState(() {
        //     screenView = HelpScreen();
        //   });
        //   break;
        // case DrawerIndex.FeedBack:
        //   setState(() {
        //     screenView = FeedbackScreen();
        //   });
        //   break;
        // case DrawerIndex.Invite:
        //   setState(() {
        //     screenView = InviteFriend();
        //   });
        //   break;
        default:
          break;
      }
    }
  }
}
