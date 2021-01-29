import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:row_collection/row_collection.dart';

import '../../cubits/base/index.dart';
import 'index.dart';

/// TODO
class SimplePage extends StatelessWidget {
  final String title;
  final Widget body, fab;
  final List<Widget> actions;

  const SimplePage({
    @required this.title,
    @required this.body,
    this.fab,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.rubik(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: actions,
      ),
      body: body,
      floatingActionButton: fab,
    );
  }
}

/// TODO
class RequestSimplePage<C extends RequestCubit, T> extends StatelessWidget {
  final String title;
  final Widget fab;
  final RequestWidgetBuilderLoaded body;
  final List<Widget> actions;
  final void Function() onRefresh;

  const RequestSimplePage({
    @required this.title,
    @required this.body,
    this.fab,
    this.actions,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final onRefreshFunction = onRefresh ?? () => context.read<C>().loadData();

    return RefreshIndicator(
      onRefresh: onRefreshFunction,
      child: SimplePage(
        title: title,
        fab: fab,
        actions: actions,
        body: RequestBuilder<C, T>(
          onInit: (context, state) => Separator.none(),
          onLoading: (context, state) => LoadingView(),
          onLoaded: body,
          onError: (context, state, error) => ErrorView(onRefreshFunction),
        ),
      ),
    );
  }
}

/// TODO
class SliverPage extends StatelessWidget {
  final String title;
  final Widget header;
  final List<Widget> children, actions;
  final Map<String, String> popupMenu;
  final ScrollController controller;

  const SliverPage({
    @required this.title,
    @required this.header,
    this.children,
    this.actions,
    this.popupMenu,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: PageStorageKey(title),
      controller: controller,
      slivers: <Widget>[
        SliverBar(
          title: title,
          header: header,
          actions: <Widget>[
            if (popupMenu != null)
              PopupMenuButton<String>(
                itemBuilder: (context) => [
                  for (final item in popupMenu.keys)
                    PopupMenuItem(
                      value: item,
                      child: Text(FlutterI18n.translate(context, item)),
                    )
                ],
                onSelected: (text) =>
                    Navigator.pushNamed(context, popupMenu[text]),
              ),
            if (actions != null) ...actions,
          ],
        ),
        ...children,
      ],
    );
  }
}

/// TODO
class RequestSliverPage<C extends RequestCubit, T> extends StatelessWidget {
  final String title;
  final RequestWidgetBuilderLoaded<T> headerBuilder;
  final RequestListBuilderLoaded<T> childrenBuilder;
  final List<Widget> actions;
  final Map<String, String> popupMenu;
  final void Function() onRefresh;
  final ScrollController controller;

  const RequestSliverPage({
    @required this.title,
    @required this.headerBuilder,
    @required this.childrenBuilder,
    this.controller,
    this.actions,
    this.popupMenu,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final onRefreshFunction = onRefresh ?? () => context.read<C>().loadData();
    return RefreshIndicator(
      onRefresh: onRefreshFunction,
      child: RequestBuilder<C, T>(
        onInit: (context, state) => SliverPage(
          controller: controller,
          title: title,
          header: Separator.none(),
          actions: actions,
          popupMenu: popupMenu,
        ),
        onLoading: (context, state) => SliverPage(
          controller: controller,
          title: title,
          header: LoadingView(),
          actions: actions,
          popupMenu: popupMenu,
          children: [LoadingSliverView()],
        ),
        onLoaded: (context, state, value) => SliverPage(
          controller: controller,
          title: title,
          header: headerBuilder(context, state, value),
          actions: actions,
          popupMenu: popupMenu,
          children: childrenBuilder(context, state, value),
        ),
        onError: (context, state, error) => SliverPage(
          controller: controller,
          title: title,
          header: Separator.none(),
          actions: actions,
          popupMenu: popupMenu,
          children: [ErrorSliverView(onRefreshFunction)],
        ),
      ),
    );
  }
}