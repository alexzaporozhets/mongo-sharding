#!/bin/bash

# killing all mongodb process
kill $(ps aux | grep [m]ongo | awk '{print $2}')

mkdir -p data/a0
mkdir -p data/a1
mkdir -p data/a2
mkdir -p data/b0
mkdir -p data/b1
mkdir -p data/b2
mkdir -p data/c0
mkdir -p data/c1
mkdir -p data/c2

mkdir -p data/cfg0
mkdir -p data/cfg1
mkdir -p data/cfg2

mkdir logs


# config servers
mongod --configsvr --dbpath data/cfg0 --port 26050 --fork --logpath logs/log.cfg0 --logappend
mongod --configsvr --dbpath data/cfg1 --port 26051 --fork --logpath logs/log.cfg1 --logappend
mongod --configsvr --dbpath data/cfg2 --port 26052 --fork --logpath logs/log.cfg2 --logappend

# shared servers
mongod --shardsvr --replSet a --dbpath data/a0 --logpath logs/log.a0 --port 27000 --fork --logappend --smallfiles --oplogSize 50
mongod --shardsvr --replSet a --dbpath data/a1 --logpath logs/log.a1 --port 27001 --fork --logappend --smallfiles --oplogSize 50
mongod --shardsvr --replSet a --dbpath data/a2 --logpath logs/log.a2 --port 27002 --fork --logappend --smallfiles --oplogSize 50
mongod --shardsvr --replSet b --dbpath data/b0 --logpath logs/log.b0 --port 27100 --fork --logappend --smallfiles --oplogSize 50
mongod --shardsvr --replSet b --dbpath data/b1 --logpath logs/log.b1 --port 27101 --fork --logappend --smallfiles --oplogSize 50
mongod --shardsvr --replSet b --dbpath data/b2 --logpath logs/log.b2 --port 27102 --fork --logappend --smallfiles --oplogSize 50
mongod --shardsvr --replSet c --dbpath data/c0 --logpath logs/log.c0 --port 27200 --fork --logappend --smallfiles --oplogSize 50
mongod --shardsvr --replSet c --dbpath data/c1 --logpath logs/log.c1 --port 27201 --fork --logappend --smallfiles --oplogSize 50
mongod --shardsvr --replSet c --dbpath data/c2 --logpath logs/log.c2 --port 27202 --fork --logappend --smallfiles --oplogSize 50

# mongos (query balanser)
mongos --configdb localhost:26050,localhost:26051,localhost:26052 --fork --logappend --logpath logs/log.mongos0


# init replica-sets
mongo --port 27000 --eval "rs.initiate({_id: 'a', members: [ {_id: 0, host: 'localhost:27000'}, {_id: 1, host: 'localhost:27001'}, {_id: 2, host: 'localhost:27002'}]})"
mongo --port 27100 --eval "rs.initiate({_id: 'b', members: [ {_id: 0, host: 'localhost:27100'}, {_id: 1, host: 'localhost:27101'}, {_id: 2, host: 'localhost:27102'}]})"
mongo --port 27200 --eval "rs.initiate({_id: 'c', members: [ {_id: 0, host: 'localhost:27200'}, {_id: 1, host: 'localhost:27201'}, {_id: 2, host: 'localhost:27202'}]})"

# wait for all replicas
mongo --port 27200 --eval ""

# init sharding
mongo --eval "sh.addShard('a/localhost:27000');sh.addShard('b/localhost:27100');sh.addShard('c/localhost:27200')"
