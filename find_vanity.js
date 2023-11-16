const fs = require("fs");
const micro_ipfs = require('./micro_ipfs.js');
const jsonp = fs.readFileSync(process.argv[2], 'utf-8');
const directory_hashes = JSON.parse(jsonp.substring('jsonp_ipfs_directory_hashes('.length, jsonp.length - ');\n'.length));
console.log(micro_ipfs.ipfs_self_hash.find_vanity_node(process.argv[3], 0, directory_hashes));