# Base image: ubuntu:22.04
FROM ubuntu:22.04

# ARGs
# https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG TARGETPLATFORM=linux/amd64,linux/arm64
ARG DEBIAN_FRONTEND=noninteractive

# neo4j 2025.08.0 installation (match GDS v2.21.0) and some cleanup
RUN apt-get update && \
    apt-get install -y wget gnupg software-properties-common && \
    wget -O - https://debian.neo4j.com/neotechnology.gpg.key | apt-key add - && \
    echo 'deb https://debian.neo4j.com stable latest' > /etc/apt/sources.list.d/neo4j.list && \
    add-apt-repository universe && \
    apt-get update && \
    apt-get install -y nano unzip neo4j=1:2025.08.0 python3-pip && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# TODO: Complete the Dockerfile
WORKDIR /cse511/

COPY yellow_tripdata_2022-03.parquet /cse511/

COPY data_loader.py /cse511/

# Install Java (OpenJDK 21)
RUN apt-get update && \
    apt-get install -y openjdk-21-jdk wget apt-transport-https gnupg && \
    export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64 && \
    echo "export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64" >> /etc/environment

# Install Neo4j
#RUN wget -O - https://debian.neo4j.com/neotechnology.gpg.key | apt-key add - && \
#    echo 'deb https://debian.neo4j.com stable 5' > /etc/apt/sources.list.d/neo4j.list && \
#    apt-get update && \
#    apt-get install -y neo4j

# Set initial Neo4j password to graphprocessing (Neo4j 5 syntax)
RUN neo4j-admin dbms set-initial-password graphprocessing || true

RUN pip3 install --upgrade pip && \
    pip3 install neo4j pandas pyarrow

# Install Neo4j Graph Data Science (GDS) plugin v2.21.0
RUN wget https://github.com/neo4j/graph-data-science/releases/download/2.21.0/neo4j-graph-data-science-2.21.0.jar \
    -O /var/lib/neo4j/plugins/neo4j-graph-data-science-2.21.0.jar

# Configure Neo4j
RUN echo "dbms.default_listen_address=0.0.0.0" >> /etc/neo4j/neo4j.conf && \
    echo "dbms.security.auth_enabled=true" >> /etc/neo4j/neo4j.conf && \
    echo "dbms.security.procedures.unrestricted=gds.*,apoc.*" >> /etc/neo4j/neo4j.conf && \
    echo "dbms.security.procedures.allowlist=gds.*,apoc.*" >> /etc/neo4j/neo4j.conf && \
    echo "dbms.connector.bolt.listen_address=:7687" >> /etc/neo4j/neo4j.conf && \
    echo "dbms.connector.http.listen_address=:7474" >> /etc/neo4j/neo4j.conf && \
    echo "dbms.memory.heap.initial_size=512m" >> /etc/neo4j/neo4j.conf && \
    echo "dbms.memory.heap.max_size=1G" >> /etc/neo4j/neo4j.conf && \
    echo "dbms.memory.pagecache.size=512m" >> /etc/neo4j/neo4j.conf


# Run the data loader script
RUN chmod +x /cse511/data_loader.py && \
    neo4j start && \
    python3 data_loader.py && \
    neo4j stop

# Expose neo4j ports
EXPOSE 7474 7687

# Start neo4j service and show the logs on container run
CMD ["/bin/bash", "-c", "neo4j start && tail -f /dev/null"]
