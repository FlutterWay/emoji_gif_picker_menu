import 'package:emoji_gif_picker_menu/controller/menu_state_controller.dart';
import 'package:emoji_gif_picker_menu/views/picker_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:get/get.dart';
import 'package:platform_info/platform_info.dart';

import '../models/menu_design.dart';

class EmojiGifMenuStack extends StatelessWidget {
  bool isKeyboardOpened = false;
  @override
  Widget build(BuildContext context) {
    return KeyboardSizeProvider(
      child: Overlay(
        initialEntries: [
          OverlayEntry(
              builder: ((context) =>
                  Consumer<ScreenHeight>(builder: (context, screenHeight, child) {
                    updateKeyboardStatus(screenHeight);
                    return GetBuilder<MenuStateController>(
                        builder: ((controller) {
                      return controller.isOpened &&
                              controller.currentMenu!.fromStack == true
                          ? Platform.I.isMobile
                              ? viewMobile(controller)
                              : Positioned(
                                  bottom: controller.menuPosition.bottom,
                                  top: controller.menuPosition.top,
                                  right: controller.menuPosition.right,
                                  left: controller.menuPosition.left,
                                  child: PickerMenu(
                                      onBackSpacePressed: controller
                                          .currentMenu!.onBackSpacePressed,
                                      onEmojiSelected: controller
                                          .currentMenu!.onEmojiSelected,
                                      onGifSelected:
                                          controller.currentMenu!.onGifSelected,
                                      textEditingController: controller
                                          .currentMenu!.textEditingController,
                                      sizes: controller.menuSizes,
                                      colors: controller.menuColors,
                                      styles: controller.menuStyles,
                                      texts: controller.menuTexts,
                                      giphyApiKey: controller.giphyApiKey))
                          : SizedBox();
                    }));
                  })))
        ],
      ),
    );
  }

  void updateKeyboardStatus(ScreenHeight screenHeight) {
    Get.find<MenuStateController>()
        .updateKeyboardStatus(screenHeight.isOpen, screenHeight.keyboardHeight);
  }

  Widget viewMobile(MenuStateController controller) {
    MenuSizes sizes;
    if (controller.isKeyboardOpened) {
      sizes = MenuSizes(width: controller.menuSizes.width, height: 150);
    } else {
      sizes = controller.menuSizes;
    }
    return Positioned(
      bottom: controller.isKeyboardOpened?controller.keyboardHeight:0,
      child: PickerMenu(
          sizes: sizes,
          onBackSpacePressed: controller.currentMenu!.onBackSpacePressed,
          onEmojiSelected: controller.currentMenu!.onEmojiSelected,
          onGifSelected: controller.currentMenu!.onGifSelected,
          colors: controller.menuColors,
          textEditingController: controller.currentMenu!.textEditingController,
          styles: controller.menuStyles,
          texts: controller.menuTexts,
          giphyApiKey: controller.giphyApiKey),
    );
  }
}
