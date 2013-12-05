import json
from precache import precached_verbs

f = open("precache.json", "w")
print json.dumps(precached_verbs)
json.dump(precached_verbs, f)
