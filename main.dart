import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final BannerAd myBanner = BannerAd(
    adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test Ad Unit
    size: AdSize.banner,
    request: AdRequest(),
    listener: BannerAdListener(
      onAdLoaded: (Ad ad) => print('Ad loaded.'),
      onAdFailedToLoad: (Ad ad, LoadAdError error) {
        ad.dispose();
        print('Ad failed to load: $error');
      },
    ),
  )..load();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Test AdMob Banner')),
        body: Column(
          children: [
            Expanded(child: Center(child: Text('Content here'))),
            Container(
              height: myBanner.size.height.toDouble(),
              width: myBanner.size.width.toDouble(),
              child: AdWidget(ad: myBanner),
            ),
          ],
        ),
      ),
    );
  }
}
