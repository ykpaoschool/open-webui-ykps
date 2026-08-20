ARG OPEN_WEBUI_VERSION=main
FROM ghcr.io/open-webui/open-webui:${OPEN_WEBUI_VERSION}

USER root

# System packages for document conversion (pandoc + LibreOffice), used by
# Open WebUI's RAG/ingestion pipeline. libreoffice-core is an apt package,
# not a pip package, so it belongs here rather than in requirements.txt.
RUN apt-get update \
    && apt-get install -y --no-install-recommends pandoc libreoffice-core \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt