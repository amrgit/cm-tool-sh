#!/bin/bash

if [ "$1" == "-h" ] || [ "$1" == "-help" ]; then
  echo ""
  echo "Usage: bash enable-agent.sh CM_HOST TLS_ENABLED"
  echo "  CM_HOST:     Cloudera Manager Host URL, without port number"
  echo "  CLUSTER:     The name of the cluster to update"
  echo "  SERVICE:     The service to update, values can be hive, impala, hdfs etc"
  echo "  TLS_ENABLED: Whether Cloudera Manager already has TLS enabled or not, "
  echo "               used to determine the URL to use"
  echo ""
  exit
fi

set -e

HOST=$1
CLUSTER=$2
SERVICE=$3
TLS_ENABLED=$4

BASE_DIR=$(dirname $0)
source $BASE_DIR/../../../config.sh $HOST $TLS_ENABLED

# https://www.cloudera.com/documentation/enterprise/latest/topics/cm_sg_ssl_yarn_mr_hdfs.html 

echo ""
echo "Updating YARN SSL configurations"
echo "$API_URL/cm/config $CM_USER:$CM_PASS $INSECURE"
curl -X PUT -H "Content-Type:application/json" -u $CM_USER:$CM_PASS $INSECURE \
  -d "{ \"items\": [ { \"name\": \"ssl_server_keystore_location\", \"value\": \"$CERT_DIR/server.jks\" }, { \"name\": \"ssl_server_keystore_keypassword\", \"value\": \"$KEYSTORE_PASS\" }, { \"name\": \"ssl_server_keystore_password\", \"value\": \"$KEYSTORE_PASS\" }, { \"name\": \"ssl_client_truststore_password\", \"value\": \"$TRUSTSTORE_PASS\" }, { \"name\": \"ssl_client_truststore_location\", \"value\": \"$JAVA_HOME/jre/lib/security/jssecacerts\" }, { \"name\": \"hadoop_secure_web_ui\", \"value\": \"true\" } ] }" \
  "$API_URL/clusters/$CLUSTER/services/$SERVICE/config"

echo ""
echo "DONE"
echo ""
