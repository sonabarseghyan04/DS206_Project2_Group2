import logging
from logging.handlers import RotatingFileHandler
import os


class CustomRotatingFileHandler(RotatingFileHandler):
    """
    A rotating file handler that ensures the log directory exists before writing logs.
    Rotates when log file reaches maxBytes size & keeps backupCount archives.
    """

    def __init__(self, filename, max_bytes=5_000_000, backup_count=5, level=logging.INFO):
        log_dir = os.path.dirname(filename)
        if log_dir and not os.path.exists(log_dir):
            os.makedirs(log_dir)

        super().__init__(
            filename,
            maxBytes=max_bytes,
            backupCount=backup_count,
            encoding='utf-8'
        )

        self.setLevel(level)


def get_rotating_logger(name: str, log_file: str):
    """
    Returns a configured logger with rotating file handler.
    """
    logger = logging.getLogger(name)
    logger.setLevel(logging.INFO)

    if not logger.handlers:
        handler = CustomRotatingFileHandler(filename=log_file)
        formatter = logging.Formatter(
            "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
        )
        handler.setFormatter(formatter)
        logger.addHandler(handler)

    return logger
