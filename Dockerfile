ARG OPEN_WEBUI_VERSION=main
FROM ghcr.io/open-webui/open-webui:${OPEN_WEBUI_VERSION}

USER root

COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

USER 1000