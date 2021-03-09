from setup_spark import TestSparkContext as ts

def first_test():
    spark = ts.initiate_context()
    df = spark.read.parquet("Location of parquet file")
    # Print Data frame columns
    print(df.columns)

def main():
    print("Hello World!")
    first_test()
    # ETC ETC

if __name__ == "__main__":
    main()
