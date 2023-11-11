const directory_hashes = require('./directory_hashes.js');
const micro_ipfs = require('./micro_ipfs.js');
console.log(micro_ipfs.ipfs_self_hash.find_vanity_node(null, 'soy', 0, directory_hashes.ipfs_directory_hashes));