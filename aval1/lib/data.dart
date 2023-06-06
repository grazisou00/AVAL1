import 'dart:io';
import 'dart:convert';
import 'package:xml/xml.dart' as xml;

abstract class Data {
  void load(String fileName);
  void save(String fileName);
  void clear();
  bool get hasData;
  String get data;
  set data(String value);
  List<String> get fields;
}

abstract class DelimitedData extends Data {
  String get delimiter;
}

class JsonData extends Data {
  List<dynamic> _data = [];

  JsonData() {
    _data;
  }

  @override
  void load(String fileName) {
    try {
      File file = File(fileName);
      String jsonString = file.readAsStringSync();

      _data = jsonDecode(jsonString);
    } catch (e) {
      throw Exception('Falha ao carregar dados do arquivo JSON:$e');
    }
  }

  @override
  void save(String fileName) {
    try {
      File file = File(fileName);
      String jsonString = jsonEncode(_data);
      file.writeAsStringSync(jsonString);
    } catch (e) {
      throw Exception('Falha ao salvar dados do arquivo JSON: $e');
    }
  }

  @override
  void clear() {
    _data.clear();
  }

  @override
  bool get hasData => _data.isNotEmpty;

  @override
  String get data => jsonEncode(_data);

  @override
  set data(String value) {
    _data = jsonDecode(value);
  }

  @override
  List<String> get fields {
    List<String> fieldNames = [];

    if (_data.isNotEmpty) {
      if (_data[0] is Map<String, dynamic>) {
        fieldNames = _data[0].keys.toList();
      }
    }

    return fieldNames;
  }
}

class CsvData extends DelimitedData {
  List<List<String>> _data = [];
  List<String> _fields = [];
  final String _delimiter = ',';

  CsvData() {
    _data;
    _fields;
  }

  @override
  void load(String fileName) {
    try {
      File file = File(fileName);
      List<String> lines = file.readAsLinesSync();

      _fields = lines[0].split(_delimiter);
      _data = lines.sublist(1).map((line) => line.split(_delimiter)).toList();
    } catch (e) {
      throw Exception('Falha ao carregar dados do arquivo CSV:$e');
    }
  }

  @override
  void save(String fileName) {
    try {
      File file = File(fileName);
      List<String> lines = [
        _fields.join(_delimiter),
        ..._data.map((row) => row.join(_delimiter))
      ];
      file.writeAsStringSync(lines.join('\n'));
    } catch (e) {
      throw Exception('Falha ao salvar dados do arquivo CSV:$e');
    }
  }

  @override
  void clear() {
    _data.clear();
    _fields.clear();
  }

  @override
  bool get hasData => _data.isNotEmpty;

  @override
  String get data {
    List<String> lines = [
      _fields.join(_delimiter),
      ..._data.map((row) => row.join(_delimiter))
    ];
    return lines.join('\n');
  }

  @override
  set data(String value) {
    List<String> lines = value.split('\n');
    _fields = lines[0].split(_delimiter);
    _data = lines.sublist(1).map((line) => line.split(_delimiter)).toList();
  }

  @override
  List<String> get fields => List.from(_fields);

  @override
  String get delimiter => _delimiter;
}

class TsvData extends DelimitedData {
  List<List<String>> _data = [];
  List<String> _fields = [];
  final String _delimiter = '\t';

  TsvData() {
    _data;
    _fields;
  }

  @override
  void load(String fileName) {
    try {
      File file = File(fileName);
      List<String> lines = file.readAsLinesSync();

      _fields = lines[0].split(_delimiter);
      _data = lines.sublist(1).map((line) => line.split(_delimiter)).toList();
    } catch (e) {
      throw Exception('Falha ao carregar dados do arquivo TSV:$e');
    }
  }

  @override
  void save(String fileName) {
    try {
      File file = File(fileName);
      List<String> lines = [
        _fields.join(_delimiter),
        ..._data.map((row) => row.join(_delimiter))
      ];
      file.writeAsStringSync(lines.join('\n'));
    } catch (e) {
      throw Exception('Falha ao salvar dados do arquivo TSV:$e');
    }
  }

  @override
  void clear() {
    _data.clear();
    _fields.clear();
  }

  @override
  bool get hasData => _data.isNotEmpty;

  @override
  String get data {
    List<String> lines = [
      _fields.join(_delimiter),
      ..._data.map((row) => row.join(_delimiter))
    ];
    return lines.join('\n');
  }

  @override
  set data(String value) {
    List<String> lines = value.split('\n');
    _fields = lines[0].split(_delimiter);
    _data = lines.sublist(1).map((line) => line.split(_delimiter)).toList();
  }

  @override
  List<String> get fields => List.from(_fields);

  @override
  String get delimiter => _delimiter;
}

class XmlData extends Data {
  List<Map<String, String>> _data = [];
  List<String> _fields = [];

  XmlData();

  @override
  void load(String fileName) {
    try {
      final file = File(fileName);
      final xmlString = file.readAsStringSync();

      final document = xml.XmlDocument.parse(xmlString);
      final rootNode = document.rootElement;

      if (rootNode.name.local == 'data') {
        _fields = [];
        _data = [];

        for (var recordNode in rootNode.children) {
          if (recordNode is xml.XmlElement &&
              recordNode.name.local == 'record') {
            final recordData = <String, String>{};

            for (var attribute in recordNode.attributes) {
              recordData[attribute.name.local] = attribute.value;
              if (!_fields.contains(attribute.name.local)) {
                _fields.add(attribute.name.local);
              }
            }

            _data.add(recordData);
          }
        }
      }
    } catch (e) {
      throw Exception('Falha ao carregar dados do arquivo XML:$e');
    }
  }

  @override
  void save(String fileName) {
    try {
      final builder = xml.XmlBuilder();
      builder.element('data', nest: () {
        for (var recordData in _data) {
          builder.element('record', nest: () {
            for (var entry in recordData.entries) {
              builder.attribute(entry.key, entry.value);
            }
          });
        }
      });
      final xmlDoc = builder.buildDocument();

      final file = File(fileName);
      file.writeAsStringSync(xmlDoc.toXmlString(pretty: true, indent: '\t'));
    } catch (e) {
      throw Exception('Falha Salvar dados do arquivo XML:$e');
    }
  }

  @override
  void clear() {
    _data.clear();
    _fields.clear();
  }

  @override
  bool get hasData => _data.isNotEmpty;

  @override
  String get data {
    final builder = xml.XmlBuilder();
    builder.element('data', nest: () {
      for (var recordData in _data) {
        builder.element('record', nest: () {
          for (var entry in recordData.entries) {
            builder.attribute(entry.key, entry.value);
          }
        });
      }
    });
    final xmlDoc = builder.buildDocument();

    return xmlDoc.toXmlString(pretty: true, indent: '\t');
  }

  @override
  set data(String value) {
    final document = xml.XmlDocument.parse(value);
    final rootNode = document.rootElement;

    if (rootNode.name.local == 'data') {
      _fields = [];
      _data = [];

      for (var recordNode in rootNode.children) {
        if (recordNode is xml.XmlElement && recordNode.name.local == 'record') {
          final recordData = <String, String>{};

          for (var attribute in recordNode.attributes) {
            recordData[attribute.name.local] = attribute.value;
            if (!_fields.contains(attribute.name.local)) {
              _fields.add(attribute.name.local);
            }
          }

          _data.add(recordData);
        }
      }
    }
  }

  @override
  List<String> get fields => List.from(_fields);
}
