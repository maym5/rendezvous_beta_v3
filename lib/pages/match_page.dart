import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/constants.dart';
import 'package:rendezvous_beta_v3/services/match_data_service.dart';
import 'package:rendezvous_beta_v3/widgets/match_card.dart';
import 'package:rendezvous_beta_v3/widgets/match_tile.dart';
import 'package:rendezvous_beta_v3/widgets/page_background.dart';

class DatesPage extends StatefulWidget {
  const DatesPage({Key? key}) : super(key: key);

  @override
  State<DatesPage> createState() => _DatesPageState();
}

class _DatesPageState extends State<DatesPage> {
  final Stream<List<MatchData>?> _datesStream = MatchDataService().datesStream;

  Widget get _emptyMessage => Container(
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height,
        child: const Text("Such empty, get swiping!"),
      );

  Widget get _errorMessage => Container(
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height,
        child: const Text(
            "There's been an error loading your dates data, try again soon"),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: StreamBuilder(
          stream: _datesStream,
          builder: (BuildContext context,
              AsyncSnapshot<List<MatchData>?> dateSnapshot) {
            if (dateSnapshot.hasData && !dateSnapshot.hasError) {
              return ListView.builder(
                  itemCount: dateSnapshot.data!.length,
                  itemBuilder: (context, index) =>
                      DateCard(data: dateSnapshot.data![index]));
            } else if (!dateSnapshot.hasData) {
              return _emptyMessage;
            } else {
              return _errorMessage;
            }
          }),
    );
  }
}

class LikesPage extends StatefulWidget {
  const LikesPage({Key? key}) : super(key: key);

  @override
  State<LikesPage> createState() => _LikesPageState();
}

class _LikesPageState extends State<LikesPage> {
  final Stream<List<MatchData>?> _likesStream = MatchDataService().likesStream;

  Widget get _noLikesMessage => Container(
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height,
        child: const Text("Don't worry, people are liking you right now!"),
      );

  Widget get _errorMessage => Container(
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height,
        child: const Text(
            "There's been an error loading your match data, try again soon"),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: StreamBuilder<List<MatchData>?>(
          stream: _likesStream,
          builder: (BuildContext context,
              AsyncSnapshot<List<MatchData>?> likeSnapshot) {
            if (likeSnapshot.hasData && !likeSnapshot.hasError) {
              // TODO: make this a reorderable gridview
              return GridView.builder(
                itemCount: likeSnapshot.data!.length,
                itemBuilder: (BuildContext context, int index) =>
                    MatchTile(data: likeSnapshot.data![index]),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 0.8,
                    crossAxisCount: 2,
                    mainAxisSpacing: 16.0,
                    crossAxisSpacing: 8.0),
              );
            } else if (!likeSnapshot.hasData) {
              return _noLikesMessage;
            } else {
              return _errorMessage;
            }
          }),
    );
  }
}

class NewLikesPage extends StatefulWidget {
  const NewLikesPage({Key? key}) : super(key: key);

  @override
  State<NewLikesPage> createState() => _NewLikesPageState();
}

class _NewLikesPageState extends State<NewLikesPage> {
  final Stream<QuerySnapshot> _likesStream = MatchDataService().newLikeStream;

  Widget get _noLikesMessage => Container(
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height,
        child: const Text("Don't worry, people are liking you right now!"),
      );

  Widget get _errorMessage => Container(
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height,
        child: const Text(
            "There's been an error loading your match data, try again soon"),
      );

  Widget get _noInternet => Container(
    alignment: Alignment.center,
    child: Text(
      "You don't have any internet connection",
      style: kTextStyle,
      textAlign: TextAlign.center,
    ),
  );

  Widget _likeBuilder(
      BuildContext context, AsyncSnapshot<QuerySnapshot> likeSnapshot) {
    if (likeSnapshot.hasData && !likeSnapshot.hasError && likeSnapshot.data?.size != 0) {
      final List<MatchData> matchData = [];
      for (DocumentSnapshot doc in likeSnapshot.data!.docs) {
        if (doc.exists && doc.data() != null) {
          final Map _data = doc.data() as Map;
          matchData.add(MatchData(
              name: _data["name"],
              matchID: _data["matchUID"],
              image: _data["avatarImage"],
              age: _data["age"]));
        }
      }
      return GridView.builder(
        itemCount: matchData.length,
        itemBuilder: (BuildContext context, int index) =>
            MatchTile(data: matchData[index]),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 0.8,
            crossAxisCount: 2,
            mainAxisSpacing: 16.0,
            crossAxisSpacing: 8.0),
      );
    } else if (!likeSnapshot.hasData || likeSnapshot.data?.size == 0) {
      return _noLikesMessage;
    } else {
      return _errorMessage;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: StreamBuilder<QuerySnapshot>(
          stream: _likesStream,
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot> likeSnapshot) {
            switch(likeSnapshot.connectionState) {
              case ConnectionState.none: return _noInternet;
              case ConnectionState.waiting: return const CircularProgressIndicator(color: Colors.redAccent);
              case ConnectionState.active: return _likeBuilder(context, likeSnapshot);
              case ConnectionState.done: return _likeBuilder(context, likeSnapshot);
            }
          }),
    );
  }
}

class NewDatePage extends StatefulWidget {
  const NewDatePage({Key? key}) : super(key: key);

  @override
  State<NewDatePage> createState() => _NewDatePageState();
}

class _NewDatePageState extends State<NewDatePage> {
  final Stream<QuerySnapshot> _datesStream = MatchDataService().newDateData;

  Widget get _emptyMessage => Container(
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height,
        child: const Text("Such empty, get swiping!"),
      );

  Widget get _errorMessage => Container(
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height,
        child: const Text(
            "There's been an error loading your dates data, try again soon"),
      );

  Widget get _noInternet => Container(
        alignment: Alignment.center,
        child: Text(
          "You don't have any internet connection",
          style: kTextStyle,
          textAlign: TextAlign.center,
        ),
      );

  Widget _dateBuilder(
      BuildContext context, AsyncSnapshot<QuerySnapshot> dateSnapshot) {
    if (dateSnapshot.hasData &&
        !dateSnapshot.hasError &&
        dateSnapshot.data!.size != 0) {
      final List<MatchData> matchData = [];
      for (DocumentSnapshot doc in dateSnapshot.data!.docs) {
        if (doc.exists && doc.data() != null) {
          final Map _data = doc.data() as Map;
          matchData.add(MatchData(
            name: _data["name"],
            age: _data["age"],
            image: _data["avatarImage"],
            matchID: _data["matchUID"],
            venue: _data["venue"],
            dateType: _data["dateType"],
            dateTime: MatchDataService.convertTimeStamp(_data["dateTime"]),
          ));
        }
      }
      return ListView.builder(
          itemCount: matchData.length,
          itemBuilder: (context, index) => DateCard(data: matchData[index]));
    } else if (!dateSnapshot.hasData || dateSnapshot.data!.size == 0) {
      return _emptyMessage;
    } else {
      return _errorMessage;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: StreamBuilder<QuerySnapshot>(
          stream: _datesStream,
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot> dateSnapshot) {
            switch (dateSnapshot.connectionState) {
              case ConnectionState.done:
                return _dateBuilder(context, dateSnapshot);
              case ConnectionState.waiting:
                return const CircularProgressIndicator(color: Colors.redAccent);
              case ConnectionState.none:
                return _noInternet;
              case ConnectionState.active:
                return _dateBuilder(context, dateSnapshot);
            }
          }),
    );
  }
}

class MatchPage extends StatefulWidget {
  const MatchPage({Key? key}) : super(key: key);
  static const id = "match_page";

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  Widget get _dates => const NewDatePage();

  Widget get _likes => const NewLikesPage();

  List<Widget> get _children => [_dates, _likes];

  static const List<Tab> _tabs = <Tab>[
    Tab(
      text: "Dates",
    ),
    Tab(
      text: "Likes",
    )
  ];

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageBackground(
      appBar: AppBar(
        leading: const BackButton(color: Colors.transparent),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs,
          indicatorColor: Colors.redAccent,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: _children,
      ),
    );
  }
}
