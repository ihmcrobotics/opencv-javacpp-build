#!/bin/bash
# Rewrite opencv/pom.xml to us.ihmc and 4.10.0-1.5.11-${VERSION_DATE}-ihmc
set -euo pipefail
VERSION_DATE="${VERSION_DATE:-$(date +%Y%m%d)}"
sed -i.bak '12s/.*/  <groupId>us.ihmc<\/groupId>/' opencv/pom.xml
sed -i "s|<version>4.10.0-\${project.parent.version}</version>|<version>4.10.0-\${project.parent.version}-${VERSION_DATE}-ihmc</version>|" opencv/pom.xml
