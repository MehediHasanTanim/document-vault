import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/files/encrypted_file_store.dart';
import '../../../core/files/file_reference.dart';
import '../application/viewer/secure_viewer_session.dart';

/// Full-screen image viewer. Each page has a private session only while it is
/// visible; leaving the screen deletes every plaintext temporary artifact.
class SecureImageViewerScreen extends StatefulWidget {
  const SecureImageViewerScreen({
    required this.store,
    required this.pages,
    this.initialPage = 0,
    super.key,
  });
  final EncryptedFileStore store;
  final List<SecureFileReference> pages;
  final int initialPage;

  @override
  State<SecureImageViewerScreen> createState() =>
      _SecureImageViewerScreenState();
}

class _SecureImageViewerScreenState extends State<SecureImageViewerScreen> {
  late final PageController _pages;
  SecureViewerSession? _session;
  Uint8List? _bytes;
  Object? _error;
  var _index = 0;
  var _quarterTurns = 0;
  var _loadToken = 0;

  @override
  void initState() {
    super.initState();
    _index = widget.initialPage.clamp(0, widget.pages.length - 1);
    _pages = PageController(initialPage: _index);
    _open(_index);
  }

  @override
  void dispose() {
    _pages.dispose();
    _session?.close();
    super.dispose();
  }

  Future<void> _open(int index) async {
    final token = ++_loadToken;
    await _session?.close();
    if (mounted) {
      setState(() {
        _bytes = null;
        _error = null;
        _quarterTurns = 0;
      });
    }
    try {
      final session = await SecureViewerSession.open(
        widget.store,
        widget.pages[index],
      );
      final bytes = await session.file.readAsBytes();
      if (!mounted || token != _loadToken) {
        await session.close();
        return;
      }
      _session = session;
      setState(() => _bytes = bytes);
    } on Object catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    body: SafeArea(
      child: Stack(
        children: [
          PageView.builder(
            controller: _pages,
            itemCount: widget.pages.length,
            onPageChanged: (index) {
              _index = index;
              _open(index);
            },
            itemBuilder: (_, page) =>
                page == _index ? _imageBody() : const SizedBox.expand(),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: IconButton(
              tooltip: 'Back / ফিরে যান',
              color: Colors.white,
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              tooltip: 'Rotate view / ঘুরিয়ে দেখুন',
              color: Colors.white,
              onPressed: () =>
                  setState(() => _quarterTurns = (_quarterTurns + 1) % 4),
              icon: const Icon(Icons.rotate_right),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Text(
              '${_index + 1} / ${widget.pages.length}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _imageBody() {
    if (_error != null) {
      return const Center(
        child: Text(
          'Could not open image / ছবিটি খোলা যায়নি',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
    if (_bytes == null) return const Center(child: CircularProgressIndicator());
    return Center(
      child: InteractiveViewer(
        minScale: 0.8,
        maxScale: 5,
        child: RotatedBox(
          quarterTurns: _quarterTurns,
          child: Image.memory(_bytes!, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

/// PDF UI is renderer-agnostic so the application can select a vetted native
/// renderer per platform. The renderer receives a private, scoped PDF file and
/// yields pixels only to this in-memory screen.
class SecurePdfViewerScreen extends StatefulWidget {
  const SecurePdfViewerScreen({
    required this.store,
    required this.pdf,
    required this.renderer,
    super.key,
  });
  final EncryptedFileStore store;
  final SecureFileReference pdf;
  final SecurePdfRenderer<Uint8List> renderer;

  @override
  State<SecurePdfViewerScreen> createState() => _SecurePdfViewerScreenState();
}

class _SecurePdfViewerScreenState extends State<SecurePdfViewerScreen> {
  SecureViewerSession? _session;
  Uint8List? _page;
  Object? _error;
  var _pageIndex = 0;
  var _pageCount = 0;

  @override
  void initState() {
    super.initState();
    _open();
  }

  @override
  void dispose() {
    _session?.close();
    super.dispose();
  }

  Future<void> _open() async {
    try {
      final session = await SecureViewerSession.open(widget.store, widget.pdf);
      final count = await widget.renderer.pageCount(session.file);
      if (!mounted) {
        await session.close();
        return;
      }
      _session = session;
      _pageCount = count;
      await _render();
    } on Object catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  Future<void> _render() async {
    final session = _session;
    if (session == null || _pageCount == 0) return;
    setState(() => _page = null);
    try {
      final page = await widget.renderer.renderPage(
        session.file,
        _pageIndex,
        scale: 1.5,
      );
      if (mounted) setState(() => _page = page);
    } on Object catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      title: Text(
        _pageCount == 0 ? 'PDF / পিডিএফ' : '${_pageIndex + 1} / $_pageCount',
      ),
    ),
    body: _error != null
        ? const Center(
            child: Text(
              'Could not open PDF / পিডিএফ খোলা যায়নি',
              style: TextStyle(color: Colors.white),
            ),
          )
        : _page == null
        ? const Center(child: CircularProgressIndicator())
        : InteractiveViewer(
            minScale: 0.8,
            maxScale: 5,
            child: Center(child: Image.memory(_page!)),
          ),
    bottomNavigationBar: _pageCount < 2
        ? null
        : BottomAppBar(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  tooltip: 'Previous page / আগের পৃষ্ঠা',
                  onPressed: _pageIndex == 0
                      ? null
                      : () {
                          setState(() => _pageIndex--);
                          _render();
                        },
                  icon: const Icon(Icons.chevron_left),
                ),
                Text('${_pageIndex + 1} / $_pageCount'),
                IconButton(
                  tooltip: 'Next page / পরের পৃষ্ঠা',
                  onPressed: _pageIndex + 1 >= _pageCount
                      ? null
                      : () {
                          setState(() => _pageIndex++);
                          _render();
                        },
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
  );
}
