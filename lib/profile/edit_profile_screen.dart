import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supervision/profile/our_button.dart';
import 'package:supervision/profile/profile_controller.dart';
import 'package:supervision/screens/color_all.dart';
import 'package:velocity_x/velocity_x.dart';

class EditProfileScreen extends StatelessWidget {
  final dynamic data;
  const EditProfileScreen({Key? key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<ProfileController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Profile"),
        backgroundColor: kAppBarColor,
      ),
      body: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20,),
            //if data image url and controller path is empty

            data['imageUrl'] == '' && controller.profileImgPath.isEmpty
                ? Image.asset('images/profile.jpg',
                        width: 100, fit: BoxFit.fill)
                    .box
                    .roundedFull
                    .clip(Clip.antiAlias)
                    .make()
                //if data is not empty but controller path is empty
                : data['imageUrl'] != '' && controller.profileImgPath.isEmpty
                    ? Image.network(
                        data['imageUrl'],
                        width: 100,
                        fit: BoxFit.cover,
                      ).box.roundedFull.clip(Clip.antiAlias).make()
                    //if controller path not empty but data url is empty

                    : Image.file(
                        File(controller.profileImgPath.value),
                        width: 100,
                        fit: BoxFit.cover,
                      ).box.roundedFull.clip(Clip.antiAlias).make(),
            10.heightBox,
            ourButton(
                color: kAppBarColor,
                onPress: () {
                  controller.changeImage(context);
                },
                textColor: Colors.white,
                title: "Change"),
            const Divider(),
            20.heightBox,

            if (controller.isloading.value) const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.red),
                  ) else SizedBox(
                    width: context.screenWidth - 150,
                    child: ourButton(
                        color: kAppBarColor,
                        onPress: () async {
                          controller.isloading(true);
                          //if image is not selected
                          if (controller.profileImgPath.value.isNotEmpty) {
                            await controller.uploadProfileImage();
                            //VxToast.show(context, msg: "Updated");
                          } else {
                            controller.profileImageLink = data['imageUrl'];
                          }

                          await controller.updateProfile(
                            imgUrl: controller.profileImageLink,

                          );
                          Navigator.pop(context);

                        },
                        textColor: Colors.white,
                        title: "Save"),
                  ),
          ],
        )

      ),
    );
  }
}
