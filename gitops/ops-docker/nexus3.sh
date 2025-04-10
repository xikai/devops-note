mkdir /data/nexus-data
chown -R 200 /data/nexus-data
docker run -d -p 8081:8081 --name nexus -v /data/nexus-data:/nexus-data sonatype/nexus3