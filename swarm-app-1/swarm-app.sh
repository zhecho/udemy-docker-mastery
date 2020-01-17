# create networking 
docker network create -d overlay frontend
docker network create -d overlay backend

# download images    
# docker pull redis:3.2 
# docker pull postgres:9.4
# docker pull bretfisher/examplevotingapp_vote
# docker pull bretfisher/examplevotingapp_worker:java 
# docker pull bretfisher/examplevotingapp_result

# create - vote
#     - bretfisher/examplevotingapp_vote
#     - web front end for users to vote dog/cat
#     - ideally published on TCP 80. Container listens on 80
#     - on frontend network
#     - 2+ replicas of this container
docker service create --name vote -p 80:80 --network frontend --replicas 2 \
    bretfisher/examplevotingapp_vote

# create - redis
#     - redis:3.2
#     - key/value storage for incoming votes
#     - no public ports
#     - on frontend network
#     - 1 replica NOTE VIDEO SAYS TWO BUT ONLY ONE NEEDED
docker service create --name redis --network frontend --replicas 2 redis:3.2

# create - worker
#     - bretfisher/examplevotingapp_worker:java
#     - backend processor of redis and storing results in postgres
#     - no public ports
#     - on frontend and backend networks
#     - 1 replica
docker service create --name worker --network frontend --network backend --replicas 1\
    bretfisher/examplevotingapp_worker:java

# create - db
#     - postgres:9.4
#     - one named volume needed, pointing to /var/lib/postgresql/data
#     - on backend network
#     - 1 replica
docker service create --name db --network backend --replicas 1 \
  --mount type=volume,source=db-data,target=/var/lib/postgresql/data \
  postgres:9.4

# create - result
#     - bretfisher/examplevotingapp_result
#     - web app that shows results
#     - runs on high port since just for admins (lets imagine)
#     - so run on a high port of your choosing (I choose 5001), container listens on 80
#     - on backend network
#     - 1 replica
docker service create --name result -p 4001:80 --network backend --replicas 1 \
    bretfisher/examplevotingapp_result





