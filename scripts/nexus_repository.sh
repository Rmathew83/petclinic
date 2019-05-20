#!/bin/bash +xe

#Makes repository
#This command does not work with the single quotes around it in the prebuild section.
curl -H "Content-Type: application/json" -X POST -d @./scripts/repo.json -u admin:admin123 $NEXUS_URL/service/local/repositories