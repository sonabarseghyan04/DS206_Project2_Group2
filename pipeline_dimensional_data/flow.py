from pipeline_dimensional_data.tasks import run_full_pipeline
from utils import generate_uuid


class DimensionalDataFlow:
    def __init__(self):
        """
        Initialize the dimensional data flow object.
        Generates a unique execution_id for tracking/monitoring.
        """
        self.execution_id = generate_uuid()

    def exec(self, start_date: str, end_date: str):
        """
        Execute all tasks sequentially with given start and end dates.

        :param start_date: str, start date of data ingestion
        :param end_date: str, end date of data ingestion
        :return: dict with execution status and execution_id
        """

        result = run_full_pipeline(
            start_date=start_date,
            end_date=end_date,
            execution_id=self.execution_id
        )

        result["execution_id"] = self.execution_id
        return result


if __name__ == "__main__":
    pipeline = DimensionalDataFlow()
    status = pipeline.exec(start_date="2025-01-01", end_date="2025-12-31")
    print(status)
