FROM python:3.11-slim

WORKDIR /app

RUN apt-get update \
  && apt-get install -y --no-install-recommends git ca-certificates \
  && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 https://github.com/jackculpan/flightclaw.git .

RUN pip install --no-cache-dir "flights==0.9.0" "mcp[cli]" fastmcp

RUN python3 -c "from pathlib import Path; p=Path('/app/server.py'); s=p.read_text(); old='mcp = _MCP(\"flightclaw\")'; new='try:\n    mcp = _MCP(\"flightclaw\", stateless_http=True)\nexcept TypeError:\n    mcp = _MCP(\"flightclaw\")'; assert old in s, 'linha mcp não encontrada'; p.write_text(s.replace(old, new))"

RUN mkdir -p /app/data

ENV HOST=0.0.0.0
ENV PORT=8000
ENV PYTHONUNBUFFERED=1

EXPOSE 8000

CMD ["python3", "server.py", "--http"]