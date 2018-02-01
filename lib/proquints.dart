///////////////////////////////
/// svantepolk - 24.01.2018 ///
///////////////////////////////

import 'dart:typed_data';

abstract class Proquint {
    // int to letter maps
    static List<String> vowels = [ 'a', 'i', 'o', 'u' ];
    static List<String> consonants = [ 'b', 'd', 'f', 'g',
                                       'h', 'j', 'k', 'l',
                                       'm', 'n', 'p', 'r',
                                       's', 't', 'v', 'z' ];

    // letter to int maps
    static Map<String, int> consonantValues = { 'b': 0, 'd': 1, 'f': 2, 'g': 3,
                                                'h': 4, 'j': 5, 'k': 6, 'l': 7,
                                                'm': 8, 'n': 9, 'p': 10, 'r': 11,
                                                's': 12, 't': 13, 'v': 14, 'z': 15 };

    static Map<String, int> vowelValues = { 'a': 0, 'i': 1, 'o': 2, 'u': 3 };

    // values for bit masking and shifting
    static final int vowelMask = 0x3;
    static final int vowelBits = 2;

    static final int consonantMask = 0xF;
    static final int consonantBits = 4;

    /// Encode a , writing it into a StringBuffer.
    static void encodeInt16ToBuffer(StringBuffer buffer, int value) {
        
        if (value & 0xFFFF != value) {
            throw new ArgumentError('Cannot encode integers requiring larger than 16 bits.');
        }

        int c3 = (consonantMask & value);
        value = value >> consonantBits;

        int v2 = (vowelMask & value);
        value = value >> vowelBits;
        
        int c2 = (consonantMask & value);
        value = value >> consonantBits;

        int v1 = (vowelMask & value);
        value = value >> vowelBits;

        int c1 = (consonantMask & value);
        value = value >> consonantBits;

        buffer.write(consonants[c1]);
        buffer.write(vowels[v1]);
        buffer.write(consonants[c2]);
        buffer.write(vowels[v2]);
        buffer.write(consonants[c3]);
    }

    /// 
    /// return: The proquint String representing value
    static String encodeInt16(int value) {
        StringBuffer buffer = new StringBuffer();
        encodeInt16ToBuffer(buffer, value);
        return buffer.toString();
    }

    static String encodeUint8List(Uint8List bytes, {String separator: '-'}) {
        if (bytes.length % 2 != 0) {
            throw new ArgumentError('Can only encode bytes in pairs.');
        }

        StringBuffer buffer = new StringBuffer();
        int value;
        for (int i = 0; i < bytes.length; i += 2) {
            // concat the bytes into a short
            value = bytes[i] << 8;
            value |= bytes[i+1];
            encodeInt16ToBuffer(buffer, value);
            if (i < bytes.length - 2) {
                buffer.write(separator);
            }
        }

        return buffer.toString();
    }

    /// Decode a single proquint.
    /// returns: A number from 0x0000 to 0xFFFF inclusive
    static int decodeProquint(String proquint) {
        if (proquint.length != 5) {
            throw new ArgumentError('Not a valid proquint.');
        }
        
        int result = 0;

        for (int i = 0; i < proquint.length; i++) {
            if (i % 2 == 0) {
                result = result | consonantValues[proquint[i]];
                // for all except the last letter, shift the bits to make room for the next number
                if (i < proquint.length - 1) {
                    result = result << vowelBits;
                }
            } else {
                result = result | vowelValues[proquint[i]];
                result = result << consonantBits;
            }
        }
        return result;
    }

    static Uint8List decodeToUint8List(String text, {String separator: '-'}) {
        List<String> proquints = text.split(separator);
        Uint8List values = new Uint8List(proquints.length * 2);
        for (int i = 0; i < proquints.length; i++) {
            int value = decodeProquint(proquints[i]);
            values[i * 2] = (value & 0xFF00) >> 8;
            values[i * 2 + 1] = value & 0x00FF;
        }

        return values;
    }
}