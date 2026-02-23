import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';

class SleepyFixtureDetector extends AbstractDetector {
  @override
  get testSmellName => "Sleepy Fixture";

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if ((node.name == "sleep" &&
                node.parent?.beginToken.toString() == "sleep" ||
            (node.name == "delayed" &&
                node.parent?.beginToken.toString() == "Future")) &&
        node.parent is MethodInvocation) {
      testSmells.add(createSmell(node));
    }
    super.visitSimpleIdentifier(node);
  }

  @override
  String getDescription() {
    return '''
    Explicitly causing a thread to sleep can lead to unexpected results as the processing time for a 
    task can differ on different devices. Developers introduce this smell when they need to pause 
    execution of statements in a test method for a certain duration (i.e. simulate an external 
    event) and then continuing with execution.
    ''';
  }

  @override
  String getExample() {
    return '''
    test("SleepyFixture1",
      () async {
        await Future.delayed(Duration(seconds: 1));
        expect((2+2), 4, reason: "Verificando o valor 123");
        });

  test("SleepyFixture2", () async {
    m.sleep(1);
    expect((2+2), 4, reason: "Verificando o valor 123");
    });

  test("SleepyFixture3", () async {
    m.delayed(1);
    expect((2+2), 4, reason: "Verificando o valor 123");
    });

  test("SleepyFixture4", () async{
    delayed(1);
    expect((2+2), 4, reason: "Verificando o valor 123");
    });
    ''';
  }
}
