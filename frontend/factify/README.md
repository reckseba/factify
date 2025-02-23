# factify

A new Flutter project.

## Getting Started

Asuming you have flutter, android sdk up and running.

- Convert: `cat relevante-personen-2025-02-20-20-55-00.csv | python3 -c 'import csv, json, sys; print(json.dumps([dict(r) for r in csv.DictReader(sys.stdin)]))' | jq > ./assets/relevante-personen.json`
- Run `flutter pub get`
- Run `flutter run ./lib/main.dart` and choose your environment
