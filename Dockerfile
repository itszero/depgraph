FROM python:3.8.7-slim-buster

RUN pip install poetry

ADD . /code
WORKDIR /code
RUN poetry install --no-dev
RUN poetry run python -c "import stanza; stanza.download(lang='en', dir='./stanza_resources', processors='tokenize,mwt,pos,lemma,depparse')"
RUN poetry run python -c "import stanza; stanza.download(lang='ja', dir='./stanza_resources', processors='tokenize,mwt,pos,lemma,depparse')"

CMD poetry run ./server.py

