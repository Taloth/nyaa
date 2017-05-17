#!/bin/bash

set -e

# Add elasticsearch as command if needed
if [ "${1:0:1}" = '-' ]; then
	set -- elasticsearch "$@"
fi

setup_clustering() {

  if [ -n "$CLUSTER" ]; then
    OPTS="$OPTS -E cluster.name=$CLUSTER"
  fi

  if [ -n "$NODE_NAME" ]; then
    OPTS="$OPTS -E node.name=$NODE_NAME"
  fi

  if [ -n "$UNICAST_HOSTS" ]; then
    OPTS="$OPTS -E discovery.zen.ping.unicast.hosts=$UNICAST_HOSTS"
  fi

  if [ -n "$PUBLISH_AS" ]; then
    OPTS="$OPTS -E transport.publish_host=$(echo $PUBLISH_AS | awk -F: '{print $1}')"
    OPTS="$OPTS -E transport.publish_port=$(echo $PUBLISH_AS | awk -F: '{if ($2) print $2; else print 9300}')"
  fi

  if [ -n "$MIN_MASTERS" ]; then
    OPTS="$OPTS -E discovery.zen.minimum_master_nodes=$MIN_MASTERS"
  fi

}

setup_personality() {

  if [ -n "$TYPE" ]; then
    case $TYPE in
      MASTER_DATA)
        OPTS="$OPTS -E node.master=true -E node.data=true"
        ;;
      
      MASTER)
        OPTS="$OPTS -E node.master=true -E node.data=false"
        ;;

      GATEWAY)
        OPTS="$OPTS -E node.master=false -E node.data=false"
        ;;

      DATA|NON_MASTER)
        OPTS="$OPTS -E node.master=false -E node.data=true"
        ;;

      *)
        echo "Unknown node type. Please use MASTER|GATEWAY|DATA|NON_MASTER"
        exit 1
    esac
  fi

}

# Drop root privileges if we are running elasticsearch
# allow the container to be started with `--user`
if [ "$1" = 'elasticsearch' -a "$(id -u)" = '0' ]; then
	# Change the ownership of /usr/share/elasticsearch/data to elasticsearch
	chown -R elasticsearch:elasticsearch /usr/share/elasticsearch/data

    OPTS="$OPTS"

    setup_personality
    setup_clustering

    set -- gosu elasticsearch "$@" $OPTS
	#exec gosu elasticsearch "$BASH_SOURCE" "$@"
fi

# As argument is not related to elasticsearch,
# then assume that user wants to run his own process,
# for example a `bash` shell to explore this image
exec "$@"