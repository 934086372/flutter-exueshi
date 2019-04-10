import 'package:flutter/material.dart';
import 'package:flutter_html_view/flutter_html_view.dart';

class Exercise extends StatefulWidget {
  final Map item;

  const Exercise({Key key, this.item}) : super(key: key);

  @override
  _ExerciseState createState() => _ExerciseState();
}

class _ExerciseState extends State<Exercise> {
  Map get item => widget.item;

  @override
  Widget build(BuildContext context) {
    return renderQuestion();
  }

  Widget renderQuestion() {
    print(item);

    // 题型
    int questionType = item['question_types'];
    print(questionType);

    switch (questionType) {
      case 1:
        break;
    }

    // 标题
    String title = '<div>' + item['question'].toString().trim() + '</div>';

    // 题目选项
    List options = item['answer'];

    // 标准答案
    String answer = item['question_standard_answer'];

    print(item['question_standard_answer'].length);

    // 题目解析
    String analysis = item['question_analyze'].toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        renderQuestionTitle(title),
        renderOptions(options, answer),
        renderDivider(),
        renderAnalysis(analysis)
      ],
    );
  }

  Widget renderDivider() {
    return Container(
      height: 10.0,
      color: Color.fromRGBO(241, 241, 241, 0.7),
    );
  }

  Widget renderQuestionTitle(title) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        color: Color.fromRGBO(255, 255, 255, 0),
        child: HtmlView(data: title));
  }

  Widget renderOptions(options, answer) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: List.generate(options.length, (index) {
          String optionItem =
              '<div>' + options[index].toString().trim() + '</div>';
          //bool isCorrect = int.parse(answer) == index;
          bool isCorrect = false;
          return Row(
            children: <Widget>[
              isCorrect
                  ? Icon(
                Icons.check_circle,
                color: Colors.blue,
              )
                  : Icon(
                Icons.radio_button_unchecked,
                color: Color.fromRGBO(153, 153, 153, 1),
              ),
              Expanded(
                child: HtmlView(
                  data: optionItem,
                ),
              )
            ],
          );
        }),
      ),
    );
  }

  Widget renderAnalysis(analysis) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '题目解析：',
            style: TextStyle(
                color: Colors.black,
                fontSize: 16.0,
                fontWeight: FontWeight.w700),
          ),
          HtmlView(
            data: analysis,
          )
        ],
      ),
    );
  }
}
