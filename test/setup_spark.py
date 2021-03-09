import configparser
import logging
import os

from pyspark import SparkConf, SparkContext
from pyspark.sql import SparkSession

class TestSparkContext:
    
    def quiet_py4j():
        """ Adjust spark logging """
        logger = logging.getLogger('py4j')
        logger.setLevel(logging.WARN)
    
    def initiate_context(conf=None):
        aws_profile = "profilename"
        config = configparser.ConfigParser()
        env=os.getenv("env")
        if(env=="prod"):
            config.read(os.path.expanduser("${HOME}/.aws/credentials"))
        else:
            print("Reading config locally!")
            config.read(os.path.expanduser("../artifact/.aws/credentials"))

        access_id = os.getenv('AWS_ACCESS_KEY_ID', config.get(aws_profile, "aws_access_key_id"))
        access_key = os.getenv('AWS_SECRET_ACCESS_KEY', config.get(aws_profile, "aws_secret_access_key"))
        aws_region = os.getenv('AWS_REGION', config.get(aws_profile, "aws_region"))
        # Configuring pyspark
        #
        os.environ['PYSPARK_SUBMIT_ARGS'] = "--packages=org.apache.hadoop:hadoop-aws:2.7.3 pyspark-shell"

        print("Starting Spark Context")
        conf = (SparkConf()
            .set("spark.sql.broadcastTimeout", 90)
            .set("spark.driver.maxResultSize", 0)
            .set("spark.driver.memory","4g")
            .set("spark.executor.memory","4g"))

        sc = SparkContext(conf=conf)
        spark = SparkSession.builder \
                            .appName('pyspark-aws-test') \
                            .config(conf=conf) \
                            .config('spark.sql.crossJoin.enabled', 'true') \
                            .getOrCreate() 

        sc.setSystemProperty("com.amazonaws.services.s3.enableV4", "true")
        hadoop_conf=sc._jsc.hadoopConfiguration()
        hadoop_conf.set("fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem")
        hadoop_conf.set("com.amazonaws.services.s3.enableV4", "true")
        hadoop_conf.set("fs.s3a.access.key", access_id)
        hadoop_conf.set("fs.s3a.secret.key", access_key)
        hadoop_conf.set("fs.s3a.connection.maximum", "100000")
        hadoop_conf.set("fs.s3a.endpoint", "s3." + aws_region + ".amazonaws.com")
        print("Spart Context is ready")
        return spark