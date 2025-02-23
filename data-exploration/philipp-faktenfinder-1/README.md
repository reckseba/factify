# Exploration of a data pipeline from Tagesschau to politicans' claims (JSON)

## Dev
initialize venv using [uv](https://docs.astral.sh/uv)
```
uv sync
```

activate venv
```
source .venv/bin/activate
```

run jupyter notebook
```
.venv/bin/jupyter lab
```

add OpenAI API key
```
touch key.txt 
```

## The explored method in steps

1. Fetch from `https://www.tagesschau.de/api2u/news?ressort=Faktenfinder`
- this returns all articles from Faktenfinder of the last 30 days in a JSON

2. Fetch each article as HTML
- xpath to the article and further cleaning methods are used to extract only the text

3. Request an OpenAI model to extract the following from each article
```
person: str
claim: str
correct: bool
explanation: str
```

