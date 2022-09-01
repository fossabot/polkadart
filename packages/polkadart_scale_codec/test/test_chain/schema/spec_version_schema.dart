const SPEC_VERSION_SCHEMA = <String, dynamic>{
  "description": "Chain spec version description",
  "type": "object",
  "properties": {
    "specName": {
      "type": "string",
    },
    "specVersion": {
      "type": "integer",
    },
    "blockNumber": {
      "description":
          "The height of the block where the given spec version was first introduced",
      "type": "integer",
      "minimum": 0
    },
    "blockHash": {
      "description":
          "The hash of the block where the given spec version was first introduced",
      "type": "string",
      "pattern": "^0x([a-fA-F0-9])+\$"
    },
    "metadata": {
      "description": "Chain metadata",
      "type": "string",
      "pattern": "^0x([a-fA-F0-9])+\$"
    }
  },
  "required": [
    "specName",
    "specVersion",
    "blockNumber",
    "blockHash",
    "metadata"
  ]
};
