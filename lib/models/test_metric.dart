class TestMetric {
  String name, testName, code;

  // Flattened from TestClass — serializable across Isolates
  String path, projectName, moduleAtual, commit;

  int start, end;
  int value;

  TestMetric({
    required this.name,
    required this.testName,
    required this.path,
    required this.projectName,
    required this.moduleAtual,
    required this.commit,
    required this.code,
    required this.start,
    required this.end,
    required this.value,
  });
}
