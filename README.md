# Книга «Clojure на производстве», второй том

[Страница книги](https://grishaev.me/clojure-in-prod-2/) с информацией о том,
где и в каком виде купить.

![](media/photos/ready/IMG_2527.jpeg)

## Сборка

Зависимости:

- git
- make
- Docker

Подготовка образов:

```bash
make docker-build-images
```

## Сборка книги

- Формат B5 для печати:

```bash
make docker-build-print
```
