import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ssurade/components/CustomAppBar.dart';
import 'package:ssurade/utils/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart';

class InformationPage extends StatefulWidget {
  const InformationPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {
  String appVer = "불러오는 중...", newVer = "-", devVer = "";

  @override
  void initState() {
    (() async {
      appVer = (await PackageInfo.fromPlatform()).version;

      try {
        var response = jsonDecode((await http.get(Uri.parse("https://api.github.com/repos/nnnlog/ssurade/releases"))).body);
        bool newVerFound = false, devVerFound = false;
        for (var obj in response) {
          if (obj["prerelease"] == false && !newVerFound) {
            newVerFound = true;
            devVerFound = true;

            newVer = obj["tag_name"].toString().substring(1); // cast to string and substring
          }
          if (obj["prerelease"] == true && !devVerFound) {
            devVerFound = true;
            devVer = obj["tag_name"].toString().substring(1); // cast to string and substring
          }
        }
        if (!newVerFound) newVer = "";
      } catch (e) {
        newVer = "";
        devVer = "";

        showToast("앱 최신 정보를 가져오지 못했습니다.");
      }

      var appVerInstance = Version.parse(appVer);
      if (newVer != "" && appVerInstance >= Version.parse(newVer)) newVer = "";
      if (devVer != "" && appVerInstance >= Version.parse(devVer)) devVer = "";
      if (newVer != "" && devVer != "" && Version.parse(newVer) >= Version.parse(devVer)) devVer = "";

      setState(() {}); // update for newVer, devVer
    })();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: customAppBar("앱 정보"),
        backgroundColor: Colors.white,
        shadowColor: const Color.fromRGBO(0, 0, 0, 0),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "SSUrade",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            const Text(
              "숭실대학교 성적/학점 조회 앱",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "앱 버전 : $appVer",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
            (newVer == "-"
                ? const Text("버전 불러오는 중...")
                : Row(
                    children: [
                      (newVer == ""
                          ? const Text(
                              "최신 버전입니다.",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Colors.blueAccent,
                              ),
                            )
                          : InkWell(
                              child: Text(
                                "버전 $newVer으로 업데이트할 수 있습니다.",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.deepOrangeAccent,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              onTap: () => launchUrl(
                                Uri.parse("https://github.com/nnnlog/ssurade/releases/tag/v$newVer"),
                                mode: LaunchMode.externalApplication,
                              ),
                            )),
                      const Text(" "),
                      (devVer == ""
                          ? const Text("")
                          : InkWell(
                              child: Text(
                                "(베타 버전 : $devVer)",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              onTap: () => launchUrl(
                                Uri.parse("https://github.com/nnnlog/ssurade/releases/tag/v$devVer"),
                                mode: LaunchMode.externalApplication,
                              ),
                            )),
                    ],
                  )),
            const Spacer(),
            const Divider(),
            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                const Text(
                  "Developed by ",
                ),
                InkWell(
                  child: const Text(
                    "박찬솔 (nlog)",
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  onTap: () => launchUrl(
                    Uri.parse("https://nlog.dev/"),
                    mode: LaunchMode.externalApplication,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 3,
            ),
            Row(
              children: const [
                Text(
                  "Designed by ",
                ),
                InkWell(
                  child: Text(
                    "이지헌",
                  ),
                )
              ],
            ),
            Text(
              "· 유어슈의 '숨쉴때 성적표' 앱의 디자인을 일부 참고하여 제작하였습니다.",
              style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w300),
            ),
          ],
        ),
      ),
    );
  }
}
