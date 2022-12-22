import 'package:emoji_gif_picker_menu/controller/mobile_search_bar_controller.dart';
import 'package:emoji_gif_picker_menu/models/menu_design.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:get/get.dart';
import 'package:giphy_api_client/giphy_api_client.dart';
import 'package:platform_info/platform_info.dart';

class MenuProperties {
  String id;
  TextEditingController? textEditingController;
  Function()? onBackSpacePressed;
  late dynamic Function(Category? category, Emoji emoji) onEmojiSelected;
  late dynamic Function(GiphyGif? gif) onGifSelected;
  FocusNode? focusNode;
  bool fromStack;

  MenuProperties(
      {required this.id,
      this.textEditingController,
      this.onBackSpacePressed,
      dynamic Function(Category? category, Emoji emoji)? onEmojiSelected,
      dynamic Function(GiphyGif? gif)? onGifSelected,
      this.fromStack = true}) {
    if (textEditingController != null) {
      focusNode = FocusNode();
      this.onEmojiSelected = (category, emoji) {
        if (Platform.I.isDesktop) {
          Get.find<MenuStateController>().close();
        }
        if (onEmojiSelected != null) {
          onEmojiSelected(category, emoji);
        }
      };
      this.onGifSelected = (gif) {
        if (Platform.I.isDesktop) {
          Get.find<MenuStateController>().close();
        }
        if (onGifSelected != null) {
          onGifSelected(gif);
        }
      };
      focusNode!.addListener(() {
        if (focusNode!.hasFocus &&
            Get.find<MenuStateController>().isOpened &&
            Get.find<MenuStateController>().currentMenu!.id != id) {
          Get.find<MenuStateController>().close();
        }
      });
    }
  }

  bool isSameMenu(MenuProperties menu) {
    return menu.id == id &&
        menu.textEditingController == textEditingController &&
        menu.onBackSpacePressed == onBackSpacePressed &&
        menu.onEmojiSelected == onEmojiSelected &&
        menu.onGifSelected == onGifSelected &&
        menu.fromStack == fromStack;
  }

  void focus() {
    if (focusNode != null) focusNode!.requestFocus();
  }

  void unfocus() {
    if (focusNode != null) focusNode!.unfocus();
  }
}

class MenuStateController extends GetxController {
  MenuColors menuColors = MenuColors();
  MenuPosition menuPosition = MenuPosition();
  MenuStyles menuStyles = MenuStyles();
  MenuTexts menuTexts = MenuTexts();
  MenuSizes menuSizes = MenuSizes(width: 0, height: 0);
  String? giphyApiKey;
  bool isKeyboardOpened = false;
  double? keyboardHeight;
  MenuProperties? currentMenu;
  List<MenuProperties> menus = [];
  void updateKeyboardStatus(bool status, double keyboardHeight) {
    isKeyboardOpened = status;
    if (this.keyboardHeight == null || this.keyboardHeight! < keyboardHeight) {
      this.keyboardHeight = keyboardHeight;
      if (keyboardHeight != 0) menuSizes.height = keyboardHeight;
    }
  }

  void setMenuProperties(MenuProperties menuProperties) {
    int index = menus.indexWhere((element) => element.id == menuProperties.id);
    if (index != -1) {
      if (!menus[index].isSameMenu(menuProperties)) {
        menus[index] = menuProperties;
        update();
      }
    } else {
      menus.add(menuProperties);
      update();
    }
  }

  bool onWillPop() {
    if (currentMenu != null) {
      if (GetInstance().isRegistered<MobileSearchBarController>() &&
          Get.find<MobileSearchBarController>().viewMobileSearchBar) {
        Get.find<MobileSearchBarController>().close();
        return false;
      } else {
        currentMenu!.unfocus();
        close();
        return false;
      }
    } else {
      return true;
    }
  }

  void close() {
    currentMenu = null;
    update();
  }

  bool get isOpened => currentMenu != null;

  bool isMenuOpened(String id) {
    return isOpened ? id == currentMenu!.id : false;
  }

  bool isValidMenu(String id) {
    return menus.any((element) => element.id == id);
  }

  MenuProperties getMenuProperties(String id) {
    return menus.singleWhere((element) => element.id == id);
  }

  void open({bool openFromStack = true, required String id}) {
    if (isOpened && currentMenu!.id != id) {
      close();
    }
    currentMenu = menus.singleWhere((element) => element.id == id);
    currentMenu!.focus();
    update();
  }
}