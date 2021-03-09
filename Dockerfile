FROM python:3.6 AS pyspark_aws

ENV PYSPARK_PYTHON "/usr/bin/python3"

RUN apt-get update && apt-get install -y python-docutils vim

RUN rm -rf /var/lib/apt/lists/* && apt-get clean && apt-get update && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

# Assuming java tar file available in current dir jdk8u161
COPY ./artifact/ /artifact
WORKDIR /artifact

RUN tar -xvf jdk-8u161-linux-x64.tar.gz
RUN mkdir -p /opt/java/jdk1.8.0_161 ; 
RUN mv jdk1.8.0_161/* /opt/java/jdk1.8.0_161;

ENV JAVA_HOME=/opt/java/jdk1.8.0_161 \
    PATH="/opt/java/jdk1.8.0_161/bin:$PATH"

CMD [ "python", "./test/test_file.py" ]