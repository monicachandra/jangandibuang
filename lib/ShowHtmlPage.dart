import 'package:flutter/material.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;

class ShowHtmlPage extends StatefulWidget {
  @override
  _TopUp2State createState() => _TopUp2State(url,nominal);

  final String url;
  final double nominal;

  ShowHtmlPage({Key key, @required this.url,@required this.nominal}) : super(key: key);
}

class _TopUp2State extends State<ShowHtmlPage> {
  String url;
  double nominal;
  Completer<WebViewController> _controller = Completer<WebViewController>();
  final Set<String> _favorites = Set<String>();

  _TopUp2State(this.url,this.nominal) {}

  void backscreen() {
    tambahSaldo();
  }

  Future<String> tambahSaldo() async{
    var url1 = Uri.parse(globals.ipnumber+'topUp');
    await http
            .post(url1, body: {'username': globals.loginuser,'idXendit':url,'nominal':nominal.toString()})
            .then((res){
              Navigator.pop(context);
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Pembayaran Dengan Xendit"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.map),
            onPressed: backscreen,
          ),
        ],
      ),
      body: WebView(
        initialUrl: url,
        javascriptMode: JavascriptMode.unrestricted,
        // withZoom: false,
      ),
    );
  }
}

class Menu extends StatelessWidget {
  Menu(this._webViewControllerFuture, this.favoritesAccessor);
  final Future<WebViewController> _webViewControllerFuture;
  // TODO(efortuna): Come up with a more elegant solution for an accessor to this than a callback.
  final Function favoritesAccessor;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _webViewControllerFuture,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> controller) {
        if (!controller.hasData) return Container();
        return PopupMenuButton<String>(
          onSelected: (String value) async {
            if (value == 'Email link') {
              var url = await controller.data.currentUrl();
              await launch(
                  'mailto:?subject=Check out this cool Wikipedia page&body=$url');
            } else {
              var newUrl = await Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return FavoritesPage(favoritesAccessor());
              }));
              Scaffold.of(context).removeCurrentSnackBar();
              if (newUrl != null) controller.data.loadUrl(newUrl);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
            const PopupMenuItem<String>(
              value: 'Email link',
              child: Text('Email link'),
            ),
            const PopupMenuItem<String>(
              value: 'See Favorites',
              child: Text('See Favorites'),
            ),
          ],
        );
      },
    );
  }
}

class FavoritesPage extends StatelessWidget {
  FavoritesPage(this.favorites);
  final Set<String> favorites;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Favorite pages')),
      body: ListView(
          children: favorites
              .map((url) => ListTile(
                  title: Text(url), onTap: () => Navigator.pop(context, url)))
              .toList()),
    );
  }
}

class NavigationControls extends StatelessWidget {
  const NavigationControls(this._webViewControllerFuture)
      : assert(_webViewControllerFuture != null);

  final Future<WebViewController> _webViewControllerFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: _webViewControllerFuture,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
        final bool webViewReady =
            snapshot.connectionState == ConnectionState.done;
        final WebViewController controller = snapshot.data;
        return Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: !webViewReady
                  ? null
                  : () => navigate(context, controller, goBack: true),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: !webViewReady
                  ? null
                  : () => navigate(context, controller, goBack: false),
            ),
          ],
        );
      },
    );
  }

  navigate(BuildContext context, WebViewController controller,
      {bool goBack: false}) async {
    bool canNavigate =
        goBack ? await controller.canGoBack() : await controller.canGoForward();
    if (canNavigate) {
      goBack ? controller.goBack() : controller.goForward();
    } else {
      Scaffold.of(context).showSnackBar(
        SnackBar(
            content: Text("No ${goBack ? 'back' : 'forward'} history item")),
      );
    }
  }
}
