import 'package:flutter/material.dart';
import 'package:foore/data/constants/feedback.dart';
import 'package:foore/data/model/feedback.dart';
import 'package:foore/review_page/reply_gmb.dart';
import 'review_page_helper.dart';

class GoogleItemWidget extends StatelessWidget {
  final FeedbackItem _feedbackItem;
  final bool isShowReplyButton;

  GoogleItemWidget(this._feedbackItem, {Key key, this.isShowReplyButton})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var onReply = () {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => ReplyGmb(this._feedbackItem),
            fullscreenDialog: true,
          ));
    };

    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          height: 1.0,
          color: Color.fromRGBO(233, 233, 233, 0.50),
        ),
        SizedBox(
          height: 20.0,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              StarDisplay(
                  value: GmbReviewHelper.getStarRating(this._feedbackItem)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    ReviewPageHelper.getCreatedTimeText(this._feedbackItem),
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
              Container(child: this.sourceLogo(this._feedbackItem))
            ],
          ),
        ),
        ListTile(
          title: Text(ReviewPageHelper.getNameText(this._feedbackItem)),
          subtitle: GmbReviewHelper.isShowGmbComment(this._feedbackItem)
              ? Text(GmbReviewHelper.getGmbCommentText(this._feedbackItem))
              : null,
        ),
        reply(this._feedbackItem),
        this.isShowReplyButton
            ? ButtonTheme.bar(
                child: ButtonBar(
                  children: <Widget>[
                    RaisedButton(
                      elevation: 0.0,
                      child: Text(
                        GmbReviewHelper.getReplyButtonText(this._feedbackItem),
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: onReply,
                    ),
                  ],
                ),
              )
            : Container(),
      ],
    );
  }

  Widget sourceLogo(FeedbackItem feedbackItem) {
    if (feedbackItem.source ==
        FeedbackSource.CONST_FEEDBACK_SOURCE_GOOGLE_REVIEW) {
      return Image(
        width: 40.0,
        image: AssetImage('assets/googlelogo.png'),
      );
    }
    return null;
  }

  Widget reply(FeedbackItem feedbackItem) {
    if (!this.isShowReplyButton) {
      return Container();
    }
    if (!GmbReviewHelper.isShowGmbReply(feedbackItem)) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        width: double.infinity,
        color: Color.fromRGBO(233, 233, 233, 0.50),
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Your reply has been posted on Google',
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.black45,
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
            Text(
              GmbReviewHelper.gmbReplyText(feedbackItem),
              style: TextStyle(
                fontSize: 14.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StarDisplay extends StatelessWidget {
  final int value;
  const StarDisplay({Key key, this.value = 0})
      : assert(value != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < value ? Icons.star : Icons.star_border,
          size: 18.0,
          color: Color.fromARGB(255, 239, 206, 74),
        );
      }),
    );
  }
}