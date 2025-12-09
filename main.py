import argparse
from pipeline_dimensional_data.flow import DimensionalDataFlow

def main():
    # ---------------------------------
    # Parse CLI arguments
    # ---------------------------------
    parser = argparse.ArgumentParser(
        description="Run the Dimensional Data Pipeline."
    )

    parser.add_argument(
        "--start_date",
        type=str,
        required=True,
        help="Start date of the data ingestion (YYYY-MM-DD)"
    )

    parser.add_argument(
        "--end_date",
        type=str,
        required=True,
        help="End date of the data ingestion (YYYY-MM-DD)"
    )

    args = parser.parse_args()

    # ---------------------------------
    # Run pipeline
    # ---------------------------------
    pipeline = DimensionalDataFlow()
    result = pipeline.exec(
        start_date=args.start_date,
        end_date=args.end_date
    )

    # ---------------------------------
    # Print final execution details
    # ---------------------------------
    print("\n===== PIPELINE EXECUTION RESULT =====")
    print(f"Execution ID: {result.get('execution_id')}")
    print(f"Success: {result.get('success')}")
    print(f"Stage: {result.get('stage')}")
    print(f"Details: {result.get('details')}\n")


if __name__ == "__main__":
    main()
