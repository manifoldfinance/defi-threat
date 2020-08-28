'use strict';
const yaml = require('js-yaml');
const fs   = require('fs');
const path = require('path');

const appDirectory = fs.realpathSync(process.cwd());
const xcveDirectory = 'ethereum/solidity/xcve'
const resolveOwn = relativePath => path.resolve(__dirname, relativePath);

function getThreatMatrix) {
  let data = [];
   try {
     const xcveDir = resolveOwn(xcveDirectory)
     fs.readdirSync(xcveDir)
       .map(item => resolveOwn(`${xcveDirectory}/${item}`))
       .forEach(filePath => data.push(yaml.safeLoad(
         fs.readFileSync(filePath, 'utf8')
       )));
     return data;
   } catch (e) {
     throw new Error(e);
   }
}

module.exports = { getThreatMatrix };