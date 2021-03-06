import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:switch_theme/blocs/movi_blocs/bloc/details_bloc.dart';
import 'package:switch_theme/blocs/movi_blocs/bloc/tvdetails_bloc.dart';
import 'package:switch_theme/core/api/constants.dart';
import 'package:switch_theme/core/models/movie_list_model.dart';
import 'package:switch_theme/core/models/tv_list.dart';
import 'package:switch_theme/shared/app_bar.dart';
import 'package:switch_theme/shared/error.dart';
import 'package:switch_theme/shared/star_rating.dart';
import 'package:switch_theme/shared/trending.dart';
import "../../core/api/constants.dart";

class TvDetailsScreen extends StatefulWidget {
  final TvResult result;
  const TvDetailsScreen({Key key, this.result}) : super(key: key);
  @override
  _TvDetailsScreenState createState() => _TvDetailsScreenState();
}

class _TvDetailsScreenState extends State<TvDetailsScreen> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<TvdetailsBloc>(context).getTvById(widget.result.id);
    BlocProvider.of<TvdetailsBloc>(context).getSimilarTv(widget.result.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: "Detail Screen",
        leading: false,
      ),
      body: buildSingleChildScrollView(context),
    );
  }

  Widget buildSingleChildScrollView(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return CustomScrollView(
      slivers: <Widget>[
        SliverList(
          delegate: SliverChildListDelegate([
            Container(
              height: 300.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Hero(
                  tag: widget?.result?.id,
                  child: Image.network(
                    "$imgUrl${widget?.result?.backdrop_path}",
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Image.asset("assets/no-image.png");
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                  child: Text(widget?.result?.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 30.0,
                          color: Theme.of(context).backgroundColor))),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                  child: Text(widget?.result?.first_air_date ?? "",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 30.0,
                          color: Theme.of(context).backgroundColor))),
            ),
            Center(
              child: MyStarRating(
                voteAverage: widget?.result?.vote_average,
                size: 40.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                widget?.result?.overview,
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 15.0, color: Theme.of(context).backgroundColor),
              ),
            ),
            BlocBuilder<TvdetailsBloc, TvDetailsState>(
              builder: (context, state) {
                return _render(context, state);
              },
            )
          ]),
        )
      ],
    );
  }

  Widget _render(BuildContext context, TvDetailsState state) {
    final height = MediaQuery.of(context).size.height;
    if (state is TvDetailsLoaded)
      return Column(
        children: <Widget>[
          Container(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Chip(
                    label: Text(
                        "Number Of Episodes : " +
                                state?.tvShow?.number_of_episodes?.toString() ??
                            "Not Mentioned",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20.0,
                            color: Theme.of(context).backgroundColor)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Chip(
                    label: Text(
                        "Number Of Seasons : " +
                            (state?.tvShow?.number_of_seasons?.toString() ??
                                "Not Mentioned"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20.0,
                            color: Theme.of(context).backgroundColor)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Chip(
                    label: Text(
                        "budget : " +
                            (state?.tvShow?.budget?.toString() ??
                                "Not Mentioned") +
                            "\$",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20.0,
                            color: Theme.of(context).backgroundColor)),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: state?.tvShow?.genres?.length == 0 ||
                    state?.tvShow?.genres == null
                ? Chip(
                    label: Text("no gender specified"),
                  )
                : Container(
                    height: 50.0,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: state?.tvShow?.genres?.length ?? 0,
                      itemBuilder: (_, i) => Chip(
                          label: Text(state?.tvShow?.genres[i]?.name ?? "",
                              style: TextStyle(
                                  color: Theme.of(context).backgroundColor))),
                    ),
                  ),
          ),
          _renderSimilarTv(state),
        ],
      );
    else if (state is TvDetailsLoading) {
      return Container(
        height: 50.0,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: LinearProgressIndicator(),
        ),
      );
    } else if (state is TvDetailsError) {
      return ErrorUi();
    } else {
      return Container(
        height: 50.0,
        child: Card(
          child: Text("No gender specified"),
          color: Theme.of(context).backgroundColor,
        ),
      );
    }
  }

  Widget _renderSimilarTv(TvDetailsState state) {
    if (state is TvDetailsLoaded) {
      return Column(
        children: <Widget>[
          Container(
            height: 50.0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Similar Tv Shows",
                  style: TextStyle(
                      fontSize: 30.0,
                      color: Theme.of(context).backgroundColor)),
            ),
          ),
          !(state?.similar?.length == 0 || state?.tvShow?.seasons == null)
              ? Container(
                  height: 300.0,
                  child: Trending(
                      context: context,
                      imgUrl: imgUrl,
                      tvItems: state?.similar ?? []),
                )
              : Container(
                  height: 50.0,
                  child: Chip(
                    label: Text("No Similar Movies",
                        style: TextStyle(
                            color: Theme.of(context).backgroundColor)),
                  ),
                ),
          Container(
            height: 50.0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Seasons",
                  style: TextStyle(
                      fontSize: 30.0,
                      color: Theme.of(context).backgroundColor)),
            ),
          ),
          !(state?.tvShow?.seasons?.length == 0 ||
                  state?.tvShow?.seasons == null)
              ? Container(
                  height: 300.0,
                  child: Trending(
                      context: context,
                      imgUrl: imgUrl,
                      seasons: state?.tvShow?.seasons ?? []),
                )
              : Container(
                  height: 50.0,
                  child: Chip(
                    label: Text("This Tv Show has Just One Season",
                        style: TextStyle(
                            color: Theme.of(context).backgroundColor)),
                  ),
                ),
        ],
      );
    } else if (state is TvDetailsLoading) {
      return Container(
          height: 50.0,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: LinearProgressIndicator(),
          ));
    }
    return SizedBox();
  }
}
