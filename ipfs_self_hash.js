var ipfs_self_hash = (function() {
  var ipfs = micro_ipfs;
  var get_root_with_vanity = function(vanity_attempt) {
    var find_link_entry = function() {
      for (var i = 0; i < ipfs_directory_hashes.tree.Links.length; i++) {
        if (ipfs_directory_hashes.tree.Links[i].Name == 'directory_hashes.js') {
          return i;
        }
      }
    }
    var foo_link_entry = find_link_entry();
    ipfs_directory_hashes.tree.Links[foo_link_entry].Hash = "";
    ipfs_directory_hashes.tree.Links[foo_link_entry].Size = 0;
    ipfs_directory_hashes.vanity_number = vanity_attempt;

    // TODO: using JSON.stringify to recreate the file is more brittle, better store the stringified version as a hex string, and then decode it?
    var file_directory_hashes = 'var ipfs_directory_hashes=' + JSON.stringify(ipfs_directory_hashes) + ';\n';
    var foo = ipfs.hashWithLinks(16, {
      "Links": [],
      "isFile": true,
      "File": ipfs.utf8StringToHex(file_directory_hashes)
    });

    ipfs_directory_hashes.tree.Links[foo_link_entry].Hash = foo.hash;
    ipfs_directory_hashes.tree.Links[foo_link_entry].Size = foo.block.length;

    root = ipfs.hashWithLinks(32, ipfs_directory_hashes.tree);
    return root;
  }

  var expected_vanity_attempt = 32*32*32;
  var max_vanity_attempt = expected_vanity_attempt*10;
  function find_vanity(old_root, vanity_text, vanity_attempt, callback) {
    var root = get_root_with_vanity(vanity_attempt);
    console.log(root.hash, vanity_attempt, vanity_text);
    if (vanity_attempt > max_vanity_attempt) {
      // give up:
      root = get_root_with_vanity(ipfs_directory_hashes.vanity_number)
      callback(root, 'timeout');
    } else {
      if (root.hash[root.hash.length-1] == vanity_text[2]) {
        callback(old_root, '… ' + vanity_attempt + ' (' + Math.floor(100*vanity_attempt/expected_vanity_attempt) + '%)');
        if (root.hash[root.hash.length-2] == vanity_text[1] && root.hash[root.hash.length-3] == vanity_text[0]) {
          callback(root, vanity_attempt);
        } else {
          window.setTimeout(function() { find_vanity(old_root, vanity_text, vanity_attempt + 1, callback); }, 0);
        }
      } else {
        window.setTimeout(function() { find_vanity(old_root, vanity_text, vanity_attempt + 1, callback); }, 0);
      }
    }
  }

  function main(show_link) {
    console.log('ipfs_self_hash a');
    var root = get_root_with_vanity(ipfs_directory_hashes.vanity_number);
    var vanity_text = ipfs_directory_hashes.vanity_text;

    console.log('ipfs_self_hash b');
    if (root.hash[root.hash.length-1] == vanity_text[2] && root.hash[root.hash.length-2] == vanity_text[1] && root.hash[root.hash.length-3] == vanity_text[0]) {
      // vanity check is ok
      console.log('ipfs_self_hash c');
      show_link(root, ipfs_directory_hashes.vanity_number);
    } else {
      // Brute-force to try to find a number that gives the desired last 3 characters
      console.log('ipfs_self_hash d');
      show_link(root, '…');
      find_vanity(root, vanity_text, 0, show_link);
    }
  }
  
  return main;
})();