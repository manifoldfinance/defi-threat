#!/usr/bin/env node

/* eslint-disable no-cond-assign */
/* eslint-disable no-undef */
/* eslint-disable no-redeclare */
const request = require("request");
const fs = require("fs");
const sleep = require("sleep");
const entities = require("html-entities").AllHtmlEntities;

var url_contracts = "https://etherscan.io/contractsVerified/";

getContracts = async function () {
  const files = getFiles("./contracts");
  var counter = 1;

  while (true) {
    try {
      var contract_list_body = await GET(url_contracts + counter);
      var re_code_url = /href\=\'\/address\/(.+?)\#code\'/gs;
      var addresses = [];

      while ((m_address = re_code_url.exec(contract_list_body))) {
        var address = m_address[1];
        if (files.indexOf(address) == -1) {
          addresses.push(address);
        }
      }

      console.log(url_contracts + counter);

      if (addresses.length == 0) {
        console.log("I am done here. No new addresses");
        //return 0;
      }

      for (var address of addresses) {
        var url_code = "https://etherscan.io/address/" + address + "#code";
        var contract_list_body = await GET(url_code);

        var re_code = /<pre\sclass\=\'js-sourcecopyarea.+?>(.+?)<\/pre>/gs;
        var m_code = re_code.exec(contract_list_body);

        var re_contract = /Name<\/span>:\s*<\/td>\s*<td>\s*(.+?)\s*<\/td>/gs;
        var m_contract = re_contract.exec(contract_list_body);

        if (m_contract !== null && m_code !== null) {
          var code = entities.decode(m_code[1]);
          var contract_name = m_contract[1];
          var location =
            "./contracts/" + address + "_" + contract_name + ".sol";

          fs.writeFile(location, code, function (err) {
            if (err) {
              return console.log(err);
            }
            console.log("Writing contract: " + contract_name);
          });
        }
      }

      counter += 1;
    } catch (error) {
      console.log("Error ... " + error);
    }
  }
};

function getFiles(dir, files_) {
  files_ = files_ || [];
  var files = fs.readdirSync(dir);
  for (var i in files) {
    var name = dir + "/" + files[i];
    if (fs.statSync(name).isDirectory()) {
      getFiles(name, files_);
    } else {
      var ad_r = /contracts\/(.+?)_/gs;
      var ad_m = ad_r.exec(name);
      files_.push(ad_m[1]);
    }
  }
  return files_;
}

function GET(url) {
  return new Promise((resolve, reject) => {
    request(url, (error, response, body) => {
      if (error) reject(error);
      if (response.statusCode != 200) {
        reject("Invalid status code <" + response.statusCode + ">");
      }
      resolve(body);
      sleep.sleep(5);
    });
  });
}

getContracts();
