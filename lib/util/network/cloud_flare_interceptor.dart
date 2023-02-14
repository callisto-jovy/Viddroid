import 'package:dio/dio.dart';
import 'package:http/http.dart';
import 'package:puppeteer/protocol/network.dart';
import 'package:puppeteer/puppeteer.dart';
import 'package:viddroid_flutter_desktop/constants.dart';
import 'package:viddroid_flutter_desktop/util/network/plugins/custom_stealth_plugin.dart';

class CloudFlareInterceptor extends Interceptor {

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {

    puppeteer.plugins.add(CustomStealthPlugin());
    // Download the Chromium binaries, launch it and connect to the "DevTools"
    var browser = await puppeteer.launch(
      headless: false,
    );

    // Open a new tab
    var page = await browser.newPage();
    await page.setJavaScriptEnabled(true);
    await page.setUserAgent(userAgent);

    await page.goto(options.path);
    //await page.click('#os_player');

    // await Future.delayed(const Duration(seconds: 5));

    final List<Cookie> cookies = await page.cookies();
    final String cookie = cookies.map((e) => '${e.name}=${e.value}').join(';');

    await browser.close();

    //Set request cookie
    options.headers['cookie'] = cookie;
    options.followRedirects = false;


    super.onRequest(options, handler);
  }


  @override
  Future<StreamedResponse> intercept(BaseRequest request) async {


    return request.send();
  }
}
