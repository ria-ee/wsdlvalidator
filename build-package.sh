#!/bin/bash
set -ex
# fetch sources
test -f apache-cxf-3.0.1-src.zip || wget https://archive.apache.org/dist/cxf/3.0.1/apache-cxf-3.0.1-src.zip
sha1sum -c apache-cxf-3.0.1-src.zip.sha1
test -d apache-cxf-3.0.1-src || unzip apache-cxf-3.0.1-src.zip

# patch sources
(cd apache-cxf-3.0.1-src
patch --forward -p1 < ../possible-delivery-3.0.1.patch
patch --forward -p0 < ../cxf_6488.patch
# build sources
(cd distribution/manifest/; mvn clean install)
mvn clean install -DskipTests

# copy resources
mkdir -p ../debian-package/root/usr/share/xroad-wsdlvalidator/lib/
find ./ \( -name "cxf-core-3.0.1.jar" \
  -or -name "cxf-manifest.jar" \
  -or -name "cxf-rt-bindings-soap-3.0.1.jar" \
  -or -name "cxf-rt-wsdl-3.0.1.jar" \
  -or -name "cxf-tools-common-3.0.1.jar" \
  -or -name "cxf-tools-validator-3.0.1.jar" \
  -or -name "stax2-api-3.1.4.jar" \
  -or -name "woodstox-core-asl-4.4.0.jar" \
  -or -name "wsdl4j-1.6.3.jar" \
  -or -name "xmlschema-core-2.1.0.jar" \
  \) -exec cp {} ../debian-package/root/usr/share/xroad-wsdlvalidator/lib/ \;
mkdir -p ../debian-package/root/usr/bin/
cp ../debian-package/wsdlvalidator ../debian-package/root/usr/bin/
cp -r licenses ../debian-package/root/usr/share/xroad-wsdlvalidator/
# done
)

# build package
(cd debian-package
dpkg-buildpackage -rfakeroot -us -uc
# done
)

# build portable package
(cd portable
mkdir -p xroad-wsdlvalidator-portable/bin/
mkdir -p xroad-wsdlvalidator-portable/lib/
cp wsdlvalidator* xroad-wsdlvalidator-portable/bin/
cp ../debian-package/root/usr/share/xroad-wsdlvalidator/lib/* xroad-wsdlvalidator-portable/lib/
cp -r ../apache-cxf-3.0.1-src/licenses xroad-wsdlvalidator-portable/
rm -f ../xroad-wsdlvalidator-portable_1.0.2.zip
zip -r ../xroad-wsdlvalidator-portable_1.0.2.zip xroad-wsdlvalidator-portable
rm -rf xroad-wsdlvalidator-portable
# all done
)
