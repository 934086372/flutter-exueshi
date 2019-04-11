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

  String groupTitle;
  String title;
  String analysis;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(item['subject_addon']);
    if (item['subject'] != null && item['subject'].toString().trim() != '') {
      groupTitle = '<div>' + filterHtml(item['subject']) + '</div>';
    }
    title = '<div>' + filterHtml(item['question'].toString().trim()) + '</div>';

    // 题目解析
    analysis = filterHtml(item['question_analyze'].toString());
  }

  @override
  Widget build(BuildContext context) {
    return renderQuestion();
  }

  Widget renderQuestion() {
    print(item['subject']);

    // 题型
    int questionType = item['question_types'];
    print(questionType);

    // 题目选项
    List options = item['answer'];

    // 标准答案
    String answer = item['question_standard_answer'];

    String exType;
    switch (questionType) {
      case 1:
        exType = '单选题';
        break;
      case 2:
        exType = '多选题';
        break;
      case 3:
        exType = '填空题';
        break;
      case 4:
        exType = '简答题';
        break;
      case 5:
        exType = '计算题';
        break;
      case 6:
        exType = '判断题';
        options = ['正确', '错误'];
        break;
      case 8:
        exType = '翻译题';
        break;
      case 9:
        exType = '写作题';
        break;
      default:
        exType = '未知题型';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        renderGroupTitle(),
        renderQuestionTitle(),
        renderOptions(options, answer),
        renderDivider(),
        renderAnalysis()
      ],
    );
  }

  Widget renderGroupTitle() {
    print(groupTitle);
    if (groupTitle == null) return Container();
    return Container(
      height: 200,
      color: Color.fromRGBO(245, 245, 245, 0.8),
      child: SingleChildScrollView(
        child: HtmlView(
          data: groupTitle,
        ),
      ),
    );
  }

  Widget renderDivider() {
    return Container(
      height: 10.0,
      color: Color.fromRGBO(241, 241, 241, 0.7),
    );
  }

  Widget renderQuestionTitle() {
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

  // 渲染题目解析部分
  Widget renderAnalysis() {
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

  // 过滤 HTML 中无法被解析的标签
  String filterHtml(data) {
    String tmp = data.toString();
    Pattern p1 = '<o:p>';
    Pattern p2 = '</o:p>';
    Pattern p3 = '&nbsp;';
    tmp = tmp.replaceAll(p1, '');
    tmp = tmp.replaceAll(p2, '');
    tmp = tmp.replaceAll(p3, ' ');
    return tmp;
  }
}
