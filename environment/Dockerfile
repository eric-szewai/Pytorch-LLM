FROM python:3.11-slim@sha256:e41613d42d4891e4930f79523f93f81bbc7632584ec65e36ab055f41a800b41e
WORKDIR /task
COPY states/before/ states/before/
COPY tests/ tests/
COPY environment/run-tests-eval.sh /test.sh
RUN chmod +x /test.sh && pip install --no-cache-dir pytest==8.3.3
ENTRYPOINT []
