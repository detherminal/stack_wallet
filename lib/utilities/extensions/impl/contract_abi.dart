import 'dart:convert';

import 'package:web3dart/web3dart.dart';

extension ContractAbiExtensions on ContractAbi {
  static ContractAbi fromJsonList({
    required String name,
    required String jsonList,
  }) {
    final List<ContractFunction> functions = [];
    final List<ContractEvent> events = [];

    final list = List<Map<String, dynamic>>.from(jsonDecode(jsonList) as List);

    for (final json in list) {
      final type = json["type"] as String;
      final name = json["name"] as String? ?? "";

      if (type == "event") {
        final anonymous = json["anonymous"] as bool? ?? false;
        final List<EventComponent<dynamic>> components = [];

        for (final input in json["inputs"] as List) {
          components.add(
            EventComponent(
              _parseParam(input as Map),
              input['indexed'] as bool? ?? false,
            ),
          );
        }

        events.add(ContractEvent(anonymous, name, components));
      } else {
        final mutability = _mutabilityNames[json['stateMutability']];
        final parsedType = _functionTypeNames[json['type']];
        if (parsedType != null) {
          final inputs = _parseParams(json['inputs'] as List?);
          final outputs = _parseParams(json['outputs'] as List?);

          functions.add(
            ContractFunction(
              name,
              inputs,
              outputs: outputs,
              type: parsedType,
              mutability: mutability ?? StateMutability.nonPayable,
            ),
          );
        }
      }
    }

    return ContractAbi(name, functions, events);
  }

  static const Map<String, ContractFunctionType> _functionTypeNames = {
    'function': ContractFunctionType.function,
    'constructor': ContractFunctionType.constructor,
    'fallback': ContractFunctionType.fallback,
  };

  static const Map<String, StateMutability> _mutabilityNames = {
    'pure': StateMutability.pure,
    'view': StateMutability.view,
    'nonpayable': StateMutability.nonPayable,
    'payable': StateMutability.payable,
  };

  static List<FunctionParameter<dynamic>> _parseParams(List<dynamic>? data) {
    if (data == null || data.isEmpty) return [];

    final elements = <FunctionParameter<dynamic>>[];
    for (final entry in data) {
      elements.add(_parseParam(entry as Map));
    }

    return elements;
  }

  static FunctionParameter<dynamic> _parseParam(Map<dynamic, dynamic> entry) {
    final name = entry['name'] as String;
    final typeName = entry['type'] as String;

    if (typeName.contains('tuple')) {
      final components = entry['components'] as List;
      return _parseTuple(name, typeName, _parseParams(components));
    } else {
      final type = parseAbiType(entry['type'] as String);
      return FunctionParameter(name, type);
    }
  }

  static CompositeFunctionParameter _parseTuple(String name, String typeName,
      List<FunctionParameter<dynamic>> components) {
    // The type will have the form tuple[3][]...[1], where the indices after the
    // tuple indicate that the type is part of an array.
    assert(RegExp(r'^tuple(?:\[\d*\])*$').hasMatch(typeName),
        '$typeName is an invalid tuple type');

    final arrayLengths = <int?>[];
    var remainingName = typeName;

    while (remainingName != 'tuple') {
      final arrayMatch = RegExp(r'^(.*)\[(\d*)\]$').firstMatch(remainingName)!;
      remainingName = arrayMatch.group(1)!;

      final insideSquareBrackets = arrayMatch.group(2)!;
      if (insideSquareBrackets.isEmpty) {
        arrayLengths.insert(0, null);
      } else {
        arrayLengths.insert(0, int.parse(insideSquareBrackets));
      }
    }

    return CompositeFunctionParameter(name, components, arrayLengths);
  }
}