import sys
from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from pyspark.sql.types import DoubleType, IntegerType


def build_spark():
    return (
        SparkSession.builder
        .appName("AmazonProductsPipeline_PA5")
        .config("spark.sql.adaptive.enabled", "true")
        .config("spark.sql.adaptive.coalescePartitions.enabled", "true")
        .getOrCreate()
    )


def load_and_clean(spark, input_path):

    raw = spark.read.csv(
        input_path,
        header=True,
        sep=",",
        quote='"',
        escape='"',
        multiLine=True,
        inferSchema=False,
    )

    cleaned = (
        raw
        .withColumn("price", F.regexp_replace(F.col("price"), "[^0-9.]", "").cast(DoubleType()))
        .withColumn("listPrice", F.regexp_replace(F.col("listPrice"), "[^0-9.]", "").cast(DoubleType()))
        .withColumn("stars", F.regexp_replace(F.col("stars"), "[^0-9.]", "").cast(DoubleType()))
        .withColumn("reviews", F.regexp_replace(F.col("reviews"), "[^0-9]", "").cast(IntegerType()))
        .withColumn("boughtInLastMonth", F.regexp_replace(F.col("boughtInLastMonth"), "[^0-9]", "").cast(IntegerType()))
        .withColumn("isBestSeller", F.when(F.col("isBestSeller") == "True", 1).otherwise(0))
    )

    cleaned = cleaned.filter(F.col("price").isNotNull() & (F.col("price") > 0))

    return cleaned


def add_features(df):

    df = df.withColumn(
        "price_bucket",
        F.when(F.col("price") < 10, "LOW")
         .when(F.col("price") < 30, "MID")
         .when(F.col("price") < 100, "HIGH")
         .otherwise("PREMIUM"),
    )

    df = df.withColumn(
        "rating_category",
        F.when(F.col("stars") >= 4, "GOOD")
         .when(F.col("stars") >= 2, "AVERAGE")
         .otherwise("LOW_OR_NONE"),
    )

    df = df.withColumn(
        "discount_amount",
        F.when(F.col("listPrice") > F.col("price"), F.col("listPrice") - F.col("price"))
         .otherwise(F.lit(None).cast(DoubleType())),
    )

    df = df.withColumn(
        "discount_pct",
        F.when(F.col("listPrice") > F.col("price"),
               (F.col("listPrice") - F.col("price")) / F.col("listPrice") * 100)
         .otherwise(F.lit(None).cast(DoubleType())),
    )

    return df


def build_main_comparison_table(df):

    return (
        df.groupBy("categoryName", "price_bucket")
        .agg(
            F.count("*").alias("product_count"),
            F.round(F.avg("listPrice"), 2).alias("avg_list_price"),
            F.round(F.avg("price"), 2).alias("avg_current_price"),
            F.round(F.avg("stars"), 2).alias("avg_stars"),
            F.round(F.avg("boughtInLastMonth"), 1).alias("avg_bought_last_month"),
            F.sum("boughtInLastMonth").alias("total_bought_last_month"),
            F.round(F.avg("discount_pct"), 2).alias("avg_discount_pct"),
        )
        .orderBy(F.desc("total_bought_last_month"))
    )


def category_summary(df):

    return (
        df.groupBy("categoryName")
        .agg(
            F.count("*").alias("category_product_count"),
            F.round(F.avg("price"), 2).alias("category_avg_price"),
            F.round(F.avg("stars"), 2).alias("category_avg_stars"),
        )
    )


def top_sellers_with_category_context(df, cat_summary):

    top = (
        df.filter(F.col("boughtInLastMonth").isNotNull())
        .orderBy(F.desc("boughtInLastMonth"))
        .limit(100)
        .select(
            "asin", "title", "categoryName", "price", "listPrice",
            "stars", "boughtInLastMonth", "price_bucket",
        )
    )

    return top.join(F.broadcast(cat_summary), on="categoryName", how="left")


def rating_vs_sales(df):
    
    return (
        df.groupBy("rating_category")
        .agg(
            F.count("*").alias("product_count"),
            F.round(F.avg("boughtInLastMonth"), 1).alias("avg_bought_last_month"),
            F.round(F.avg("price"), 2).alias("avg_price"),
            F.round(F.avg("stars"), 2).alias("avg_stars"),
        )
        .orderBy(F.desc("avg_bought_last_month"))
    )


def main():
    if len(sys.argv) < 3:
        print("Usage: amazon_products_pipeline.py <input_path> <output_path>")
        sys.exit(1)

    input_path = sys.argv[1]
    output_path = sys.argv[2].rstrip("/")

    spark = build_spark()
    spark.sparkContext.setLogLevel("WARN")

    print(f"Spark version: {spark.version}")
    print(f"Reading from: {input_path}")
    print(f"Writing to:   {output_path}")


    df = load_and_clean(spark, input_path)
    df = df.repartition(16, "categoryName")
    df = add_features(df)
    df.cache()

    total_rows = df.count()
    print(f"Total cleaned rows: {total_rows}")

    main_table = build_main_comparison_table(df)
    cat_summary = category_summary(df)
    top_with_context = top_sellers_with_category_context(df, cat_summary)
    rating_table = rating_vs_sales(df)

    print("\nMain comparison table (top 20)")
    main_table.show(20, truncate=False)

    print("\nRating category vs sales")
    rating_table.show()

    print("\nTop 100 sellers with category context (sample)")
    top_with_context.select(
        "title", "categoryName", "price", "listPrice",
        "stars", "boughtInLastMonth", "category_avg_price",
    ).show(10, truncate=False)

    print("\nWriting outputs to GCS...")

    (
        main_table
        .write
        .mode("overwrite")
        .partitionBy("price_bucket")
        .parquet(f"{output_path}/main_comparison_table")
    )

    (
        rating_table
        .coalesce(1)
        .write
        .mode("overwrite")
        .option("header", True)
        .csv(f"{output_path}/rating_vs_sales")
    )

    (
        top_with_context
        .coalesce(1)
        .write
        .mode("overwrite")
        .option("header", True)
        .csv(f"{output_path}/top_sellers_with_context")
    )

    (
        cat_summary
        .coalesce(1)
        .write
        .mode("overwrite")
        .option("header", True)
        .csv(f"{output_path}/category_summary")
    )

    print("Pipeline complete.")
    df.unpersist()
    spark.stop()


if __name__ == "__main__":
    main()
