# to build and run from your local machine:
# docker build -t financepy-runner:local .
# docker run --rm financepy-runner:local

FROM python:3.12-slim

WORKDIR /app

ENV MPLBACKEND=Agg

# Install FinancePy from local source (matches `pip install -e .` dev workflow)
COPY pyproject.toml setup.py README.md LICENSE MANIFEST.in ./
COPY financepy ./financepy
COPY runner.py input.json ./

RUN pip install --no-cache-dir -U pip \
	&& pip install --no-cache-dir -e .

# Pre-warm the Numba JIT cache so first run isn't slow.
# This import triggers compilation of the core models.
RUN python -c "\
from financepy.products.bonds import Bond; \
from financepy.products.equity import EquityVanillaOption; \
from financepy.utils import *; \
print('Numba cache warmed')"

ENTRYPOINT ["python", "runner.py"]
CMD ["input.json"]