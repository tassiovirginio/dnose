import 'package:sentiment_dart/sentiment_dart.dart';

class TestSmell {
  String name, testName, code, codeMD5;
  String? codeTest;
  String? codeTestMD5;

  // Flattened from TestClass — serializable across Isolates
  String path, projectName, moduleAtual, commit;

  int start,
      end,
      startTest,
      endTest,
      offset,
      endOffset,
      collumnStart,
      collumnEnd;
  String? lineNumber, commitAuthor, author, dateStr, timeStr, summary;
  //sentiment
  double? score, comparative;
  SentimentWordCategories? words;

  TestSmell({
    required this.name,
    required this.testName,
    required this.path,
    required this.projectName,
    required this.moduleAtual,
    required this.commit,
    required this.code,
    required this.codeMD5,
    required this.start,
    required this.end,
    required this.collumnStart,
    required this.collumnEnd,
    required this.codeTest,
    required this.codeTestMD5,
    required this.startTest,
    required this.endTest,
    required this.offset,
    required this.endOffset,
  });

  int localStartLine() {
    return start - startTest;
  }

  int localEndLine() {
    return end - startTest;
  }
}
