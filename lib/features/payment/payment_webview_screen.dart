import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/theme/app_colors.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String url;
  final String title;
  final String propertyId;

  const PaymentWebViewScreen({
    super.key,
    required this.url,
    this.title = 'பாதுகாப்பான கட்டணம் (₹10)',
    required this.propertyId,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  int _loadingProgress = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..addJavaScriptChannel(
        'FlutterApp',
        onMessageReceived: (JavaScriptMessage message) {
          if (message.message == 'payment_success' || message.message == 'payment_done') {
            if (mounted) {
              Navigator.of(context).pop(true);
            }
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _loadingProgress = progress;
                _isLoading = progress < 100;
              });
            }
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            // Only flag main frame errors
            if (error.isForMainFrame ?? true) {
              if (mounted) {
                setState(() {
                  _errorMessage = error.description;
                  _isLoading = false;
                });
              }
            }
          },
          onNavigationRequest: (NavigationRequest request) async {
            final url = request.url;

            // Handle UPI, GPay, PhonePe, Paytm, and WhatsApp / Tel links
            if (url.startsWith('upi://') ||
                url.startsWith('phonepe://') ||
                url.startsWith('tez://') ||
                url.startsWith('gpay://') ||
                url.startsWith('paytmmp://') ||
                url.startsWith('intent://') ||
                url.startsWith('tel:') ||
                url.startsWith('whatsapp:') ||
                url.startsWith('https://wa.me/')) {
              try {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              } catch (_) {}
              return NavigationDecision.prevent;
            }

            // Handle return/done triggers
            if (url.contains('payment-success') || url.contains('close_webview')) {
              if (mounted) {
                Navigator.of(context).pop(true);
              }
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _openInCustomTab() async {
    final uri = Uri.parse(widget.url);
    try {
      await launchUrl(
        uri,
        mode: LaunchMode.inAppBrowserView,
        browserConfiguration: const BrowserConfiguration(showTitle: true),
      );
    } catch (_) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _controller.canGoBack()) {
          await _controller.goBack();
        } else {
          if (context.mounted) {
            Navigator.of(context).pop(false);
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D47A1),
          foregroundColor: Colors.white,
          elevation: 2,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, size: 24),
            tooltip: 'மூடு (Close)',
            onPressed: () => Navigator.of(context).pop(false),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Row(
                children: [
                  Icon(Icons.lock_rounded, size: 11, color: Color(0xFF86EFAC)),
                  SizedBox(width: 4),
                  Text(
                    '256-Bit SSL Razorpay Gateway',
                    style: TextStyle(fontSize: 11, color: Color(0xFFE2E8F0)),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 22),
              tooltip: 'புதுப்பி (Refresh)',
              onPressed: () {
                _controller.reload();
              },
            ),
            IconButton(
              icon: const Icon(Icons.open_in_browser_rounded, size: 22),
              tooltip: 'பிரவுசரில் திற (Open in Browser)',
              onPressed: _openInCustomTab,
            ),
          ],
          bottom: _isLoading
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(3),
                  child: LinearProgressIndicator(
                    value: _loadingProgress > 0 ? _loadingProgress / 100 : null,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
                    minHeight: 3,
                  ),
                )
              : null,
        ),
        body: _errorMessage != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.error),
                      const SizedBox(height: 12),
                      const Text(
                        'பக்கத்தை ஏற்றுவதில் பிழை ஏற்பட்டது',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _errorMessage = null;
                            _isLoading = true;
                          });
                          _controller.reload();
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('மீண்டும் முயற்சி செய் (Retry)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D47A1),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : WebViewWidget(controller: _controller),
      ),
    );
  }
}
