{
  "files": [
    {
      "aql": {
        "items.find": {
		  "repo": "EPMP-IGEN",
          "path": {"$match":"*"},
          "name": {"$match":"*"},
          "type": "file",
          "$or": [
            {
              "$and": [
                {
                  "modified": { "$before":"14d" }
                }
              ]
            }
          ]
        }
      }
    }
  ]
}