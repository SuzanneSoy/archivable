var lzw = (function() {
  function setBits(array, value, nbits) {
    for (var i = 0; i < nbits; i++) {
      array.push(value%2);
      value = Math.floor(value / 2);
    }
  }
  function lzwc(str) {
    var dictionary = {};
    var word = "";
    var result = [];
    var dictionarySize = 256;
    var bits = 9;
    for (var i = 0; i < 256; i++) {
      dictionary[String.fromCharCode(i)] = i;
    }
  
    for (i = 0; i < str.length; i++) {
      c = str.charAt(i);
      var newWord = word + c;
      if (dictionary.hasOwnProperty(newWord)) {
        word = newWord;
      } else {
        //result.push(dictionary[word]);
        setBits(result, dictionary[word], bits);
        dictionary[newWord] = dictionarySize++;
        if (dictionarySize == Math.pow(2, bits)) {
          bits++;
        }
        word = String(c);
      }
    }
  
    if (word !== '') {
      setBits(result, dictionary[word], bits)
      //result.push(dictionary[word]);
    }
    return result;
  }
  function getBits(array, index, nbits) {
    value = 0;
    for (i = index + nbits - 1; i >= index; i--) {
      value = (value << 1) + array[i];
    }
    return value;
  }
  function lzwd(str, strlen) {
    var dictionary = {};
    var dictionarySize = 256;
    var entry = '';
    for (var i = 0; i < 256; i++) {
      dictionary[i] = String.fromCharCode(i);
    }
    var word = String.fromCharCode(getBits(str, 0, 8));
    var result = word;
    var bits = 9;
    for (i = 9; i < strlen; i+=bits) {
      if (dictionarySize == Math.pow(2, bits) - 1) {
        bits++;
      }
      k = getBits(str, i, bits);
      if (dictionary.hasOwnProperty(k)) {
        entry = dictionary[k];
      } else {
        if (k === dictionarySize) {
          entry = word + word.charAt(0);
        } else {
          throw 'LZW decompress: Incorrect value';
        }
      }
      result += entry;
      dictionary[dictionarySize++] = word + entry.charAt(0);
      word = entry;
    }
    return result;
  }
  return { lzwc: lzwc, lzwd: lzwd }
})();