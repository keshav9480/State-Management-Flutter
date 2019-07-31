import 'package:flutter/material.dart';
import 'package:cropin_flutter/pages/set_state_page.dart';
import 'package:cropin_flutter/database.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:cropin_flutter/pages/redux_page.dart';
import 'package:cropin_flutter/pages/scoped_model_page.dart';
import 'package:cropin_flutter/pages/streams_page.dart';

enum TabItem {
  setState,
  streams,
  scopedmodule,
  redux,
}

String tabItemName(TabItem tabItem) {
  switch (tabItem) {
    case TabItem.setState:
      return "setSate";
    case TabItem.streams:
      return "Streams";
    case TabItem.scopedmodule:
      return "scopedmodules";
    case TabItem.redux:
      return "Redux";
  }
  return null;
}

class BottomNavigation extends StatefulWidget {
  BottomNavigation({Key key}) : super(key: key);

  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  TabItem currentItem = TabItem.setState;

  _onSelectItem(int index) {
    switch (index) {
      case 0:
        _updateCurrentItem(TabItem.setState);
        break;
      case 1:
        _updateCurrentItem(TabItem.streams);
        break;
      case 2:
        _updateCurrentItem(TabItem.scopedmodule);
        break;
      case 3:
        _updateCurrentItem(TabItem.redux);
        break;
    }
  }

  _updateCurrentItem(TabItem item) {
    setState(() {
      currentItem = item;
    });
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

 Widget _buildBody() {
    var database = AppFirestore();
    var stream = database.countersStream();
    switch (currentItem) {
      case TabItem.setState:
        return SetStatePage(database: database, stream: stream);
      case TabItem.streams:
        return StreamsPage(database: database, stream: stream);
      case TabItem.scopedmodule:
        return ScopedModel<CountersModel>(
          model: CountersModel(stream: stream),
          child: ScopedModelPage(database: database),
        );
      case TabItem.redux:
        var middleware = CountersMiddleware(database: database, stream: stream);
        var store = Store<ReduxModel>(
          reducer,
          initialState: ReduxModel(counters: null),
          middleware: [ middleware ],
        );
        middleware.listen(store);
        return StoreProvider(
          store: store,
          child: ReduxPage(),
        );
    }
    return Container();
  }

  _buildBottomNavigationBar() {
return  BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: [
        _buildItem(icon: Icons.adjust, tabItem: TabItem.setState),
        _buildItem(icon: Icons.clear_all, tabItem: TabItem.streams),
        _buildItem(icon: Icons.arrow_downward, tabItem: TabItem.scopedmodule),
        _buildItem(icon: Icons.settings_input_component, tabItem: TabItem.redux),
      ],
      onTap: _onSelectItem,
    );

  }

   BottomNavigationBarItem _buildItem({IconData icon, TabItem tabItem}) {
    String text = tabItemName(tabItem);
    return BottomNavigationBarItem(
      icon: Icon(
        icon,
        color: _colorTabMatching(item: tabItem),
      ),
      title: Text(
        text,
        style: TextStyle(
          color: _colorTabMatching(item: tabItem),
        ),
      ),
    );
  }

  Color _colorTabMatching({TabItem item}) {
    return currentItem == item ? Theme.of(context).primaryColor : Colors.grey;
  }

  
}
