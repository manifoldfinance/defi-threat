'use strict';
var ucs2length = require('ajv/lib/compile/ucs2length');
var validate = (function() {
  var refVal = [];
  return function validate(data, dataPath, parentData, parentDataProperty, rootData) {
    'use strict';
    var vErrors = null;
    var errors = 0;
    if (rootData === undefined) rootData = data;
    if ((data && typeof data === "object" && !Array.isArray(data))) {
      if (true) {
        var errs__0 = errors;
        var valid1 = true;
        var data1 = data.id;
        if (data1 === undefined) {
          valid1 = false;
          validate.errors = [{
            keyword: 'required',
            dataPath: (dataPath || '') + "",
            schemaPath: '#/required',
            params: {
              missingProperty: 'id'
            },
            message: 'should have required property \'id\''
          }];
          return false;
        } else {
          var errs_1 = errors;
          if (typeof data1 === "string") {
            if (ucs2length(data1) < 1) {
              validate.errors = [{
                keyword: 'minLength',
                dataPath: (dataPath || '') + '.id',
                schemaPath: '#/properties/id/minLength',
                params: {
                  limit: 1
                },
                message: 'should NOT be shorter than 1 characters'
              }];
              return false;
            } else {}
          } else {
            validate.errors = [{
              keyword: 'type',
              dataPath: (dataPath || '') + '.id',
              schemaPath: '#/properties/id/type',
              params: {
                type: 'string'
              },
              message: 'should be string'
            }];
            return false;
          }
          if (errors === errs_1) {}
          var valid1 = errors === errs_1;
        }
        if (valid1) {
          var data1 = data.title;
          if (data1 === undefined) {
            valid1 = false;
            validate.errors = [{
              keyword: 'required',
              dataPath: (dataPath || '') + "",
              schemaPath: '#/required',
              params: {
                missingProperty: 'title'
              },
              message: 'should have required property \'title\''
            }];
            return false;
          } else {
            var errs_1 = errors;
            if (typeof data1 === "string") {
              if (ucs2length(data1) < 1) {
                validate.errors = [{
                  keyword: 'minLength',
                  dataPath: (dataPath || '') + '.title',
                  schemaPath: '#/properties/title/minLength',
                  params: {
                    limit: 1
                  },
                  message: 'should NOT be shorter than 1 characters'
                }];
                return false;
              } else {}
            } else {
              validate.errors = [{
                keyword: 'type',
                dataPath: (dataPath || '') + '.title',
                schemaPath: '#/properties/title/type',
                params: {
                  type: 'string'
                },
                message: 'should be string'
              }];
              return false;
            }
            if (errors === errs_1) {}
            var valid1 = errors === errs_1;
          }
          if (valid1) {
            var data1 = data.description;
            if (data1 === undefined) {
              valid1 = false;
              validate.errors = [{
                keyword: 'required',
                dataPath: (dataPath || '') + "",
                schemaPath: '#/required',
                params: {
                  missingProperty: 'description'
                },
                message: 'should have required property \'description\''
              }];
              return false;
            } else {
              var errs_1 = errors;
              if (typeof data1 === "string") {
                if (ucs2length(data1) < 1) {
                  validate.errors = [{
                    keyword: 'minLength',
                    dataPath: (dataPath || '') + '.description',
                    schemaPath: '#/properties/description/minLength',
                    params: {
                      limit: 1
                    },
                    message: 'should NOT be shorter than 1 characters'
                  }];
                  return false;
                } else {}
              } else {
                validate.errors = [{
                  keyword: 'type',
                  dataPath: (dataPath || '') + '.description',
                  schemaPath: '#/properties/description/type',
                  params: {
                    type: 'string'
                  },
                  message: 'should be string'
                }];
                return false;
              }
              if (errors === errs_1) {}
              var valid1 = errors === errs_1;
            }
            if (valid1) {
              var data1 = data.references;
              if (data1 === undefined) {
                valid1 = false;
                validate.errors = [{
                  keyword: 'required',
                  dataPath: (dataPath || '') + "",
                  schemaPath: '#/required',
                  params: {
                    missingProperty: 'references'
                  },
                  message: 'should have required property \'references\''
                }];
                return false;
              } else {
                var errs_1 = errors;
                if (Array.isArray(data1)) {
                  var errs__1 = errors;
                  var valid1;
                  for (var i1 = 0; i1 < data1.length; i1++) {
                    var data2 = data1[i1];
                    var errs_2 = errors;
                    if ((data2 && typeof data2 === "object" && !Array.isArray(data2))) {
                      var missing2;
                      if (((data2.contract_address === undefined) && (missing2 = '.contract_address'))) {
                        validate.errors = [{
                          keyword: 'required',
                          dataPath: (dataPath || '') + '.references[' + i1 + ']',
                          schemaPath: '#/properties/references/items/required',
                          params: {
                            missingProperty: '' + missing2 + ''
                          },
                          message: 'should have required property \'' + missing2 + '\''
                        }];
                        return false;
                      } else {
                        var errs__2 = errors;
                        var valid3 = true;
                        if (errs__2 == errors) {}
                      }
                    }
                    if (errors === errs_2) {}
                    var valid2 = errors === errs_2;
                    if (!valid2) break;
                  }
                  if (errs__1 == errors) {}
                } else {
                  validate.errors = [{
                    keyword: 'type',
                    dataPath: (dataPath || '') + '.references',
                    schemaPath: '#/properties/references/type',
                    params: {
                      type: 'array'
                    },
                    message: 'should be array'
                  }];
                  return false;
                }
                if (errors === errs_1) {}
                var valid1 = errors === errs_1;
              }
              if (valid1) {
                var data1 = data.credits;
                if (data1 === undefined) {
                  valid1 = false;
                  validate.errors = [{
                    keyword: 'required',
                    dataPath: (dataPath || '') + "",
                    schemaPath: '#/required',
                    params: {
                      missingProperty: 'credits'
                    },
                    message: 'should have required property \'credits\''
                  }];
                  return false;
                } else {
                  var errs_1 = errors;
                  if (typeof data1 === "string") {
                    if (ucs2length(data1) < 1) {
                      validate.errors = [{
                        keyword: 'minLength',
                        dataPath: (dataPath || '') + '.credits',
                        schemaPath: '#/properties/credits/minLength',
                        params: {
                          limit: 1
                        },
                        message: 'should NOT be shorter than 1 characters'
                      }];
                      return false;
                    } else {}
                  } else {
                    validate.errors = [{
                      keyword: 'type',
                      dataPath: (dataPath || '') + '.credits',
                      schemaPath: '#/properties/credits/type',
                      params: {
                        type: 'string'
                      },
                      message: 'should be string'
                    }];
                    return false;
                  }
                  if (errors === errs_1) {}
                  var valid1 = errors === errs_1;
                }
                if (valid1) {
                  var data1 = data.vulnerability_type;
                  if (data1 === undefined) {
                    valid1 = false;
                    validate.errors = [{
                      keyword: 'required',
                      dataPath: (dataPath || '') + "",
                      schemaPath: '#/required',
                      params: {
                        missingProperty: 'vulnerability_type'
                      },
                      message: 'should have required property \'vulnerability_type\''
                    }];
                    return false;
                  } else {
                    var errs_1 = errors;
                    if ((data1 && typeof data1 === "object" && !Array.isArray(data1))) {
                      if (true) {
                        var errs__1 = errors;
                        var valid2 = true;
                        var data2 = data1.cwe;
                        if (data2 === undefined) {
                          valid2 = false;
                          validate.errors = [{
                            keyword: 'required',
                            dataPath: (dataPath || '') + '.vulnerability_type',
                            schemaPath: '#/properties/vulnerability_type/required',
                            params: {
                              missingProperty: 'cwe'
                            },
                            message: 'should have required property \'cwe\''
                          }];
                          return false;
                        } else {
                          var errs_2 = errors;
                          if (typeof data2 === "string") {
                            if (ucs2length(data2) < 1) {
                              validate.errors = [{
                                keyword: 'minLength',
                                dataPath: (dataPath || '') + '.vulnerability_type.cwe',
                                schemaPath: '#/properties/vulnerability_type/properties/cwe/minLength',
                                params: {
                                  limit: 1
                                },
                                message: 'should NOT be shorter than 1 characters'
                              }];
                              return false;
                            } else {}
                          } else {
                            validate.errors = [{
                              keyword: 'type',
                              dataPath: (dataPath || '') + '.vulnerability_type.cwe',
                              schemaPath: '#/properties/vulnerability_type/properties/cwe/type',
                              params: {
                                type: 'string'
                              },
                              message: 'should be string'
                            }];
                            return false;
                          }
                          if (errors === errs_2) {}
                          var valid2 = errors === errs_2;
                        }
                        if (valid2) {
                          var data2 = data1.swc;
                          if (data2 === undefined) {
                            valid2 = false;
                            validate.errors = [{
                              keyword: 'required',
                              dataPath: (dataPath || '') + '.vulnerability_type',
                              schemaPath: '#/properties/vulnerability_type/required',
                              params: {
                                missingProperty: 'swc'
                              },
                              message: 'should have required property \'swc\''
                            }];
                            return false;
                          } else {
                            var errs_2 = errors;
                            if (typeof data2 === "string") {
                              if (ucs2length(data2) < 1) {
                                validate.errors = [{
                                  keyword: 'minLength',
                                  dataPath: (dataPath || '') + '.vulnerability_type.swc',
                                  schemaPath: '#/properties/vulnerability_type/properties/swc/minLength',
                                  params: {
                                    limit: 1
                                  },
                                  message: 'should NOT be shorter than 1 characters'
                                }];
                                return false;
                              } else {}
                            } else {
                              validate.errors = [{
                                keyword: 'type',
                                dataPath: (dataPath || '') + '.vulnerability_type.swc',
                                schemaPath: '#/properties/vulnerability_type/properties/swc/type',
                                params: {
                                  type: 'string'
                                },
                                message: 'should be string'
                              }];
                              return false;
                            }
                            if (errors === errs_2) {}
                            var valid2 = errors === errs_2;
                          }
                          if (valid2) {}
                        }
                        if (errs__1 == errors) {}
                      }
                    } else {
                      validate.errors = [{
                        keyword: 'type',
                        dataPath: (dataPath || '') + '.vulnerability_type',
                        schemaPath: '#/properties/vulnerability_type/type',
                        params: {
                          type: 'object'
                        },
                        message: 'should be object'
                      }];
                      return false;
                    }
                    if (errors === errs_1) {}
                    var valid1 = errors === errs_1;
                  }
                  if (valid1) {
                    if (data.severity === undefined) {
                      valid1 = false;
                      validate.errors = [{
                        keyword: 'required',
                        dataPath: (dataPath || '') + "",
                        schemaPath: '#/required',
                        params: {
                          missingProperty: 'severity'
                        },
                        message: 'should have required property \'severity\''
                      }];
                      return false;
                    } else {
                      var errs_1 = errors;
                      if ((typeof data.severity !== "number")) {
                        validate.errors = [{
                          keyword: 'type',
                          dataPath: (dataPath || '') + '.severity',
                          schemaPath: '#/properties/severity/type',
                          params: {
                            type: 'number'
                          },
                          message: 'should be number'
                        }];
                        return false;
                      }
                      var valid1 = errors === errs_1;
                    }
                    if (valid1) {
                      var data1 = data.affected;
                      if (data1 === undefined) {
                        valid1 = false;
                        validate.errors = [{
                          keyword: 'required',
                          dataPath: (dataPath || '') + "",
                          schemaPath: '#/required',
                          params: {
                            missingProperty: 'affected'
                          },
                          message: 'should have required property \'affected\''
                        }];
                        return false;
                      } else {
                        var errs_1 = errors;
                        if ((data1 && typeof data1 === "object" && !Array.isArray(data1))) {
                          if (true) {
                            var errs__1 = errors;
                            var valid2 = true;
                            var data2 = data1.contractName;
                            if (data2 === undefined) {
                              valid2 = false;
                              validate.errors = [{
                                keyword: 'required',
                                dataPath: (dataPath || '') + '.affected',
                                schemaPath: '#/properties/affected/required',
                                params: {
                                  missingProperty: 'contractName'
                                },
                                message: 'should have required property \'contractName\''
                              }];
                              return false;
                            } else {
                              var errs_2 = errors;
                              if (typeof data2 === "string") {
                                if (ucs2length(data2) < 1) {
                                  validate.errors = [{
                                    keyword: 'minLength',
                                    dataPath: (dataPath || '') + '.affected.contractName',
                                    schemaPath: '#/properties/affected/properties/contractName/minLength',
                                    params: {
                                      limit: 1
                                    },
                                    message: 'should NOT be shorter than 1 characters'
                                  }];
                                  return false;
                                } else {}
                              } else {
                                validate.errors = [{
                                  keyword: 'type',
                                  dataPath: (dataPath || '') + '.affected.contractName',
                                  schemaPath: '#/properties/affected/properties/contractName/type',
                                  params: {
                                    type: 'string'
                                  },
                                  message: 'should be string'
                                }];
                                return false;
                              }
                              if (errors === errs_2) {}
                              var valid2 = errors === errs_2;
                            }
                            if (valid2) {
                              var data2 = data1.address;
                              if (data2 === undefined) {
                                valid2 = false;
                                validate.errors = [{
                                  keyword: 'required',
                                  dataPath: (dataPath || '') + '.affected',
                                  schemaPath: '#/properties/affected/required',
                                  params: {
                                    missingProperty: 'address'
                                  },
                                  message: 'should have required property \'address\''
                                }];
                                return false;
                              } else {
                                var errs_2 = errors;
                                if (typeof data2 === "string") {
                                  if (ucs2length(data2) < 1) {
                                    validate.errors = [{
                                      keyword: 'minLength',
                                      dataPath: (dataPath || '') + '.affected.address',
                                      schemaPath: '#/properties/affected/properties/address/minLength',
                                      params: {
                                        limit: 1
                                      },
                                      message: 'should NOT be shorter than 1 characters'
                                    }];
                                    return false;
                                  } else {}
                                } else {
                                  validate.errors = [{
                                    keyword: 'type',
                                    dataPath: (dataPath || '') + '.affected.address',
                                    schemaPath: '#/properties/affected/properties/address/type',
                                    params: {
                                      type: 'string'
                                    },
                                    message: 'should be string'
                                  }];
                                  return false;
                                }
                                if (errors === errs_2) {}
                                var valid2 = errors === errs_2;
                              }
                              if (valid2) {}
                            }
                            if (errs__1 == errors) {}
                          }
                        } else {
                          validate.errors = [{
                            keyword: 'type',
                            dataPath: (dataPath || '') + '.affected',
                            schemaPath: '#/properties/affected/type',
                            params: {
                              type: 'object'
                            },
                            message: 'should be object'
                          }];
                          return false;
                        }
                        if (errors === errs_1) {}
                        var valid1 = errors === errs_1;
                      }
                      if (valid1) {
                        var data1 = data.signature;
                        if (data1 === undefined) {
                          valid1 = false;
                          validate.errors = [{
                            keyword: 'required',
                            dataPath: (dataPath || '') + "",
                            schemaPath: '#/required',
                            params: {
                              missingProperty: 'signature'
                            },
                            message: 'should have required property \'signature\''
                          }];
                          return false;
                        } else {
                          var errs_1 = errors;
                          if (typeof data1 === "string") {
                            if (ucs2length(data1) < 1) {
                              validate.errors = [{
                                keyword: 'minLength',
                                dataPath: (dataPath || '') + '.signature',
                                schemaPath: '#/properties/signature/minLength',
                                params: {
                                  limit: 1
                                },
                                message: 'should NOT be shorter than 1 characters'
                              }];
                              return false;
                            } else {}
                          } else {
                            validate.errors = [{
                              keyword: 'type',
                              dataPath: (dataPath || '') + '.signature',
                              schemaPath: '#/properties/signature/type',
                              params: {
                                type: 'string'
                              },
                              message: 'should be string'
                            }];
                            return false;
                          }
                          if (errors === errs_1) {}
                          var valid1 = errors === errs_1;
                        }
                        if (valid1) {}
                      }
                    }
                  }
                }
              }
            }
          }
        }
        if (errs__0 == errors) {}
      }
    } else {
      validate.errors = [{
        keyword: 'type',
        dataPath: (dataPath || '') + "",
        schemaPath: '#/type',
        params: {
          type: 'object'
        },
        message: 'should be object'
      }];
      return false;
    }
    if (errors === 0) {}
    validate.errors = vErrors;
    return errors === 0;
  };
})();
validate.schema = {
  "$schema": "http://json-schema.org/draft-06/schema#",
  "description": "",
  "type": "object",
  "properties": {
    "id": {
      "type": "string",
      "minLength": 1
    },
    "title": {
      "type": "string",
      "minLength": 1
    },
    "description": {
      "type": "string",
      "minLength": 1
    },
    "references": {
      "type": "array",
      "items": {
        "required": ["contract_address"],
        "properties": {}
      }
    },
    "credits": {
      "type": "string",
      "minLength": 1
    },
    "vulnerability_type": {
      "type": "object",
      "properties": {
        "cwe": {
          "type": "string",
          "minLength": 1
        },
        "swc": {
          "type": "string",
          "minLength": 1
        }
      },
      "required": ["cwe", "swc"]
    },
    "severity": {
      "type": "number"
    },
    "affected": {
      "type": "object",
      "properties": {
        "contractName": {
          "type": "string",
          "minLength": 1
        },
        "address": {
          "type": "string",
          "minLength": 1
        }
      },
      "required": ["contractName", "address"]
    },
    "signature": {
      "type": "string",
      "minLength": 1
    }
  },
  "required": ["id", "title", "description", "references", "credits", "vulnerability_type", "severity", "affected", "signature"]
};
validate.errors = null;
module.exports = validate;