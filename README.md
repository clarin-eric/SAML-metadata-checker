# SAML-metadata-checker
Please validate your SP's SAML metadata  with this script prior to commit.

The script should be plug and play, so on Unix/Linux you can use:
$ ./check-saml-metadata/check_saml_metadata.sh  clarin-sp-metadata.xml

If the check_saml_metadata.sh does not guess JAVA_HOME correctly,
please set it explictly, e.g.
$ export JAVA_HOME=/you/path/to/jre
