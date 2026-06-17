import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.blueAccent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: WebViewScreen(),
  ));
}

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  double loadingProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setCacheMode(CacheMode.preferCache)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (int progress) => setState(() => loadingProgress = progress / 100),
        onWebResourceError: (error) => debugPrint('Error: ${error.description}'),
      ))
      ..loadRequest(Uri.parse('https://sscgroupofinstitutions.org/'));
  }

  ListTile _buildMenuTile(IconData icon, String title, String url) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: () {
        _controller.loadRequest(Uri.parse(url));
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (await _controller.canGoBack()) {
          _controller.goBack();
        } else {
          bool? exit = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Exit App'),
              content: const Text('Are you sure you want to exit?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes')),
              ],
            ),
          );
          if (exit == true) SystemNavigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("SSC Group"), backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(decoration: BoxDecoration(color: Colors.blueAccent), child: Center(child: Text('SSC Portal', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)))),
              _buildMenuTile(Icons.home, 'Home', 'https://sscgroupofinstitutions.org/'),
              _buildMenuTile(Icons.info, 'About SSC', 'https://sscgroupofinstitutions.org/about-ssc/'),
              _buildMenuTile(Icons.person, 'Faculty', 'https://sscgroupofinstitutions.org/faculty/'),
              _buildMenuTile(Icons.library_books, 'Digital Library', 'https://sscgroupofinstitutions.org/digital-library/'),
              _buildMenuTile(Icons.event, 'News & Events', 'https://sscgroupofinstitutions.org/news-events/'),
              _buildMenuTile(Icons.notifications_active, 'Notice Board', 'https://sscgroupofinstitutions.org/notice/'),
              _buildMenuTile(Icons.contact_mail, 'Contact Us', 'https://sscgroupofinstitutions.org/contact-us/'),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              if (loadingProgress < 1.0) LinearPercentIndicator(lineHeight: 4.0, percent: loadingProgress, backgroundColor: Colors.grey[200], progressColor: Colors.blueAccent),
              Expanded(child: WebViewWidget(controller: _controller)),
            ],
          ),
        ),
      ),
    );
  }
}
