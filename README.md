# proquints
"Pronounceable quintuplets of alternating unambiguous consonants and vowels."

An implementation of Proquints, as described [here](https://arxiv.org/0901.4016). In short, it is an encoding for arbitrary binary data that is easy to transmit in meatspace. Each 16 bits corresponds to a 5-letter pronouncable 'word'.

## Usage

### Encode and decode a single int
```dart
print(0x526a);
String proquint = Proquint.encodeInt16(0x526a);
print(proquint);
print(Proquint.decodeProquint(proquint));
```

### Encode an IP address
```dart
var bytes = new Uint8List.fromList(
  '192.168.10.1'
    .split('.')
    .map<int>((e) => int.parse(e))
);
var proquints = Proquint.encodeUint8List(bytes);
print(proquints);
```

### Decode it back
```dart
bytes = Proquint.decodeToUint8List(proquints);
String ip = bytes.map((e) => e.toString()).join('.');
print(ip);
```
