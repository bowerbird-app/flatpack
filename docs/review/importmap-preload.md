# Importmap modulepreload

Measured on the Rails 8 dummy with `GET /`, `GET /demo/charts`, and `GET /demo/forms/text_area`. Counts are `<link rel="modulepreload">` tags in the response.

| Page | Before | After | Heavy before | Heavy after |
| --- | --- | --- | --- | --- |
| `/` | 62 | 21 | 41 | 0 |
| `/demo/charts` | 62 | 21 | 41 | 0 |
| `/demo/forms/text_area` | 62 | 21 | 41 | 0 |

Heavy means the href contains `apexcharts`, `lowlight`, or `@tiptap`. The inline import map still names `apexcharts`, `lowlight`, and `@tiptap/core` after the change. `/demo/charts` still renders `flat-pack--chart`. `/demo/forms/text_area` still renders `flat-pack--tiptap`.
