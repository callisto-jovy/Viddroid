import 'package:dio/dio.dart';
import 'package:puppeteer/protocol/network.dart';
import 'package:puppeteer/puppeteer.dart';
import 'package:viddroid_flutter_desktop/constants.dart';
import 'package:viddroid_flutter_desktop/util/network/plugins/custom_stealth_plugin.dart';

class CloudFlareInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Download the Chromium binaries, launch it and connect to the "DevTools"
    final Browser browser =
        await puppeteer.launch(headless: false, plugins: [CustomStealthPlugin()]);

    // Open a new tab
    final Page page = await browser.newPage();
    await page.setJavaScriptEnabled(true);
    await page.setUserAgent(userAgent);
    await page
        .setExtraHTTPHeaders(options.headers.map((key, value) => MapEntry(key, value.toString())));

    await page.goto(options.path);
    //await page.click('#os_player');

    // await Future.delayed(const Duration(seconds: 5));

    final List<Cookie> cookies = await page.cookies();
    final String cookie = cookies.map((e) => '${e.name}=${e.value}').join(';');

    await browser.close();

    //Set request cookie
    options.headers['cookie'] = cookie;
    print(cookie);
    options.followRedirects = true;

    super.onRequest(options, handler);
  }
}
